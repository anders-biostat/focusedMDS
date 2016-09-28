## Creating plots for Simon presentation at Personalized Medicine Retreat
library(distnetR)
library(jsonlite)
library(Biobase)
library(pheatmap)
library(rje)
library(MASS)

## MM data

load("/Users/admin/Documents/Rotation1_AndersLab/DSRT_gen_prot_CN_RNA.RData")
tab <- exprs(DSRT) 

## Exclude drugs that are missing for more than 6 patients
tab <- tab[ rowSums(is.na(tab)) <= 6, ]
tab <- tab[ , colSums(is.na(tab)) == 0 ]

dis <- as.matrix( dist( t(tab)) )
# Send data to JSON format, for use in focused_mds.html implementation
toJSON(dis)
toJSON(colnames(dis))

hcl <- hclust(as.dist(dis))
plot(hcl)
cutree(hcl,k=5)

pheatmap( tab, col=cubeHelix(100), cluster_cols = hcl )
pheatmap( dis, col=rev(cubeHelix(100)), cluster_col=hcl, cluster_row=hcl )

pmap.clust <- as.data.frame(cutree(hcl,k=5))

toJSON(row.names(pmap.clust))
colors3 <- pmap.clust$`cutree(hcl, k = 5)`
colors3 <- sapply(colors3, as.character)

colors3[colors3 == "1"] <- "darkorange"
colors3[colors3 == "2"] <- "darkred"
colors3[colors3 == "3"] <- "steelblue"
colors3[colors3 == "4"] <- "darkgreen"
colors3[colors3 == "5"] <- "gold"

toJSON(colors3)

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
phig <- seq( 0, 2*pi, length.out=100 )

for (i in 1:nrow(dis)) {
  focus <- row.names(dis)[i]
  
  result <- focused_mds(dis,focus)
  
  png(filename= paste("focusedMDS_", i, ".png"), 
      height =6, width= 6, units= "in", res =300)
  
  colors <- pmap.clust[match(row.names(result), row.names(pmap.clust)),]
  
  plot( result$r*cos(result$phi), result$r*sin(result$phi),
        cex=1, asp=1, col = colors, xlab="", ylab="" , 
        main = paste("Focused MDS Plot", i))
  
  for( r in seq(1,200,by=20) ) lines( r*cos(phig), r*sin(phig), col="lightgray" )
  
  dev.off()
}


## Comparison to isoMDS function
dis1 <- dis
dis1[dis1 == 0] <- 0.001

iso_res <- as.data.frame(isoMDS(dis1, k=2))

x <- iso_res$points.1
y <- iso_res$points.2

colors2 <- pmap.clust[match(row.names(iso_res), row.names(pmap.clust)),]
png(filename="isoMDS_plot.png", height =6, width=6, units="in", res=300 )
plot(x,y, main= "isoMDS Plot", col= colors2)
dev.off()
