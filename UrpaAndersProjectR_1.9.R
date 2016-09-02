# Solutions to the mathematical portion of the project in R
# Lea Urpa, Simon Anders rotation in FIMM-EMBL PhD 
library(datasets)
library(distnetR)

# Load real data, generate dissimilarity matrix

load("/Users/admin/Documents/Rotation1_AndersLab/Expr.entID.expressed.rda")

tab <- Expr.entID
row.names(tab) <- Expr.entID$Sample
tab <- tab[, !names(tab) %in% c("Sample")]
#tab <- tab[,c(1:100)]

dis <- as.matrix(dist(tab))

# Focused MDS function, where the input is the matrix and the point clicked by the user

focused_mds <- function(m, focus) {
  
  obj_by_dist <- names(sort(dis[,focus]))  # sort points by distance to focus
  
  plotdata <- data.frame(r = dis[focus, obj_by_dist],  # order df by dist to focus
                         phi = NA,
                         row.names =obj_by_dist)
  
  plotdata$phi[1] <- 0         # To set focus at origin
  plotdata$phi[2] <- pi/2      # To set 2nd point on y axis
  
  new_point <- obj_by_dist[3]  # We begin optimizing on the third point
  
  
  stress <- function(phi){
    
    # position of the new point, given the candidate phi
    xnew <- plotdata[new_point,"r"] * cos(phi)
    ynew <- plotdata[new_point,"r"] * sin(phi)
    
    stress = 0
    j = 1                # the iteration variable
    
    # position of each of the previous points, iterating through the list of previously determined phis
    while (j < grep(paste("^",new_point,"$",sep=""), obj_by_dist)) {
      
      xj <- plotdata$r[j] * cos(plotdata$phi[j])
      yj <- plotdata$r[j] * sin(plotdata$phi[j])
      
      Dij = sqrt( (xnew - xj)^2 + (ynew - yj)^2)
      stress = stress + (dis[obj_by_dist[j],new_point] - Dij)^2
      j = j + 1
    }
    return(stress)
  }
  
  k <- grep(paste("^",new_point,"$",sep=""), obj_by_dist)  # the numerical position of new_point in obj_by_dist
  
  while (k <= length(obj_by_dist)) {            # iterate through the list of points and optimize with stress()
    stress_res <- optimize(stress, c(0,2*pi)) 
    #print( stress_res )
    minvalue <- stress_res$minimum
    plotdata[new_point,"phi"] <- minvalue
    
    #phigrid <- seq(0, 2*pi, length.out = 100)
    #plot(phigrid,stress(phigrid))
    #abline(v = minvalue)
    #title(main= paste(new_point, "stress graph"))
    
    k = k + 1
    new_point <- obj_by_dist[k]
  }
  result <<- plotdata
}

# Set focus to 1, then run MDS focused on the first point
focus <- 1

focused_mds(dis,focus)

# Initial plot of the data, ordered by the first data point
# User click will determine reordering of the plot

while (TRUE) {
  
  plot((result$r*cos(result$phi)), (result$r*sin(result$phi)),
       #xlim =c(), ylim= c(),
       cex=1, asp=1 )
  grid()
  
  focus <- identify((result$r*cos(result$phi)), (result$r*sin(result$phi)),
                    labels = row.names(result))
  
  focused_mds(dis,focus)
}


#distnet( dis+.1, data.frame( 
#  x = result$r*cos(result$phi),
#  y = result$r*sin(result$phi) ) )
