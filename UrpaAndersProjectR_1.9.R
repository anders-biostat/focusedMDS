# Solutions to the mathematical portion of the project in R
# Lea Urpa, Simon Anders rotation in FIMM-EMBL PhD 
library(distnetR)
library(jsonlite)
library(Biobase)
library(pheatmap)

## Interesting data so far:
##    - AML patient gene expression data, when patients distances are calculated only with top 10 most variable genes
##        -> two easily identified clusters
##    - AML voom expression of gene expression in response to drugs
##        -> interesting outliers

## AML data

# Gene expression for each patient.

    load("/Users/admin/Documents/Rotation1_AndersLab/Expr.entID.expressed.rda")  
    tab <- Expr.entID
    row.names(tab) <- Expr.entID$Sample
    tab <- tab[, !names(tab) %in% c("Sample")]

# Limma voom expression? over all patients, for genes in response to drugs

    #tab <- readRDS("/Users/admin/Documents/Rotation1_AndersLab/aml.voom.f.rds") 
    #tab <- tab[,!names(tab) %in% c("Entrez")]
    #tab <- t(tab)
    
## DSS data

# Correlation coefficients for genes and drugs, calculated over all patients

    #load("/Users/admin/Documents/Rotation1_AndersLab/corr.exp.dss.rda")      
    #tab <- corr.exp.dss[,!names(corr.exp.dss) %in% c("Genetype","Symbol","Entrez","Ensembl")]
    #tab <- t(tab)

# Correlation coefficients for genes and drugs, calculated over all patients, and averaged over genes in a gene set

    #tab <- readRDS("/Users/admin/Documents/Rotation1_AndersLab/Hs.H.tstat.rds")
    #tab <- tab[[1]]

# Getting columns with top 10 variance calculations, generate dissimilarity matrix

#tab_var <- apply(tab, 2, var)
#top_10 <- names(tail(sort(tab_var),10))
#tab <- tab[, c(top_10)]


dis <- as.matrix(dist(tab))

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


# Initial plot of the data, ordered by the first data point
# User click will determine reordering of the plot

while (TRUE) {
  
  plot( result$r*cos(result$phi), result$r*sin(result$phi),
       #xlim =c(), ylim= c(),
       cex=1, asp=1 )
  #plot(result$xcoord, result$ycoord, cex=1, asp=1)
  for( r in 1:20 ) lines( r*cos(phi), r*sin(phi), col="lightgray" )
  
    
  focus <- identify(result$r*cos(result$phi), result$r*sin(result$phi),
                    labels = row.names(result))
  
  result <- focused_mds(dis,focus)
}

## Distnet
obj_by_dist <- names(sort(dis[,focus]))  # sort points by distance to focus

dis1 <- dis[obj_by_dist,obj_by_dist]

distnet(dis1, result[,c("xcoord","ycoord")], colors = ifelse(1:52==focus, "red","black"))

## Output files to javascript format
toJSON(row.names(dis))

## Change the code to output a file in the original order, 
## and one in order of the distance of points to the focus (for plotting?)

## Stress function by itself, for optimization timing
obj_by_dist <- names(sort(dis[,focus])) 
new_point <- obj_by_dist[3]

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

system.time(optimize(stress,c(0,2*pi)))
i =0
system.time(
  while (i < 100){
    optimize(stress,c(0,2*pi))
    i = i +1
  }
  
)


