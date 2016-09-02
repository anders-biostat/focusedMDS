# Solutions to the mathematical portion of the project in R
# Lea Urpa, Simon Anders rotation in FIMM-EMBL PhD 
library(datasets)
library(distnetR)

# Load dummy data set, generate dissimilarity matrix

data("iris")
tab <- (iris[seq.int(1, nrow(iris), 6), 
            c("Petal.Length","Petal.Width","Species")])

row.names(tab) <- paste("P",row.names(tab))

species_ID <- data.frame(species = tab[,"Species"], 
                         ID = rownames(tab))

tab <- tab[, !names(tab) %in% c("Species")]

dis <- as.matrix(dist(tab))

# The goal here is to create a function that takes inputs m 
# (dissimilarity matrix) and focus (the point clicked on by 
# the user), where the output is a data table (r, phi) to plot.

focus <- 13    # The point clicked on by the user

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
    
    phigrid <- seq(0, 2*pi, length.out = 100)
    plot(phigrid,stress(phigrid))
    abline(v = minvalue)
    title(main= paste(new_point, "stress graph"))
    
    k = k + 1
    new_point <- obj_by_dist[k]
  }
  result <<- plotdata
}


# Final plot of all values (can be integrated into function once we have final
# plotting parameters)

species_ID <- (species_ID[match(row.names(result), species_ID$ID),])

plot((result$r*cos(result$phi)), (result$r*sin(result$phi)), 
     cex=2.5, asp=1, col= species_ID$species )
grid()
text((result$r*cos(result$phi)), (result$r*sin(result$phi)), 
     seq_along(rownames(result)) )

# Check the equation for the third point by comparing it to the output of the 
# stressf function.
#thirdphicheck <- acos(((dis[2,3]^2 - 2*dis[1,3]^2)/(-2*dis[1,3]))/plotdata[3,2])

distnet( dis+.1, data.frame( 
  x = result$r*cos(result$phi),
  y = result$r*sin(result$phi) ) )
