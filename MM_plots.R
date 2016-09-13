## Creating plots for Simon presentation at Personalized Medicine Retreat
library(distnetR)
library(jsonlite)
library(Biobase)
library(pheatmap)

## MM data

load("/Users/admin/Documents/Rotation1_AndersLab/DSRT_gen_prot_CN_RNA.RData")
tab <- as.data.frame(DSRT) 
na_table <- as.data.frame(colSums(is.na(tab)))  ## Exclude drugs that are missing for more than 4 patients
na_table <- subset(na_table, na_table$`colSums(is.na(tab))` <= 6)

tab <- tab[, names(tab) %in% row.names(na_table)]

dis <- as.matrix(dist(tab))

tab <- as.matrix(tab)
tab <- apply(tab, 2, as.numeric)

pmap <- pheatmap(dis)
pmap.clust <- as.data.frame(cutree(pmap$tree_col, k=5))

# Focused MDS function, where the input is the matrix and the point clicked by the user

focused_mds <- function(m, focus) {
  
  obj_by_dist <- names(sort(dis[,focus]))  # sort points by distance to focus
  
  plotdata <- data.frame(r = dis[focus, obj_by_dist],  # order df by dist to focus
                         phi = NA,
                         xcoord = NA,
                         ycoord = NA,
                         row.names =obj_by_dist)
  
  plotdata <- as.matrix(plotdata)   # handling the plotdata as a matrix is much faster
  
  plotdata[1,c("phi","xcoord","ycoord")] <- 0         # To set focus at origin, set phi, x, and y at 0
  plotdata[2,"phi"] <- pi/2           # To set 2nd point on y axis, designate phi = pi/2
  plotdata[2,"xcoord"] <- plotdata[2,"r"] * cos(plotdata[2,"phi"]) 
  plotdata[2,"ycoord"] <- plotdata[2,"r"] * sin(plotdata[2,"phi"])
  
  new_point <- obj_by_dist[3]  # We begin optimizing on the third point
  
  stress <- function(phi){
    
    stress = 0
    j = 1                # the iteration variable
    
    # position of the new point, given the candidate phi
    xnew <- plotdata[new_point,"r"] * cos(phi)
    ynew <- plotdata[new_point,"r"] * sin(phi)
    
    # position of each of the previous points, iterating through the list of previously determined phis
    
    while (j < which(new_point == obj_by_dist)) {   
      
      xj <- plotdata[j,"xcoord"]
      yj <- plotdata[j,"ycoord"]
      
      Dij =  sqrt((xnew - xj)^2 + (ynew - yj)^2)
      stress = stress + (dis[obj_by_dist[j],new_point] - Dij)^2
      j = j + 1
    }
    return(stress)
  }
  
  k <- which(new_point == obj_by_dist)          # the numerical position of new_point in obj_by_dist
  
  while (k <= length(obj_by_dist)) {            # iterate through the list of points and optimize with stress()
    stress_res <- optimize(stress, c(0,2*pi))
    minvalue <- stress_res$minimum
    plotdata[new_point,"phi"] <- minvalue
    
    plotdata[new_point, "xcoord"] <- plotdata[new_point,"r"] * cos(plotdata[new_point,"phi"])
    plotdata[new_point, "ycoord"] <- plotdata[new_point,"r"] * sin(plotdata[new_point,"phi"])
    
    #phigrid <- seq(0, 2*pi, length.out = 100)
    #plot(phigrid,stress(phigrid))
    #abline(v = minvalue)
    #title(main= paste(new_point, "stress graph"))
    
    k = k + 1
    new_point <- obj_by_dist[k]
  }
  return(as.data.frame(plotdata))
}

# Set focus to 1st member in dis

focus <- row.names(dis)[1]

# Run focused mds

result <- focused_mds(dis,focus)

##
phi <- pi
while (TRUE) {
  
  colors <- pmap.clust[match(row.names(result), row.names(pmap.clust)),]
  
  plot( result$r*cos(result$phi), result$r*sin(result$phi),
        #xlim =c(), ylim= c(),
        cex=1, asp=1, col = colors )
  #plot(result$xcoord, result$ycoord, cex=1, asp=1)
  for( r in 1:20 ) lines( r*cos(phi), r*sin(phi), col="lightgray" )
  
  focus <- identify(result$r*cos(result$phi), result$r*sin(result$phi),
                    labels = row.names(result))
  
  result <- focused_mds(dis,focus)
}
