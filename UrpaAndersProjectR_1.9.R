# Solutions to the mathematical portion of the project in R
# Lea Urpa, Simon Anders rotation in FIMM-EMBL PhD 

# Load dummy data set
library(datasets)
#data("CO2")
#CO2data <- subset(CO2, conc == 1000)
#tab <- as.matrix(CO2data$uptake)
#row.names(tab) <- CO2data$Plant

data("iris")
tab <- (iris[seq.int(1, nrow(iris), 6), 
            c("Petal.Length","Petal.Width","Species")])

row.names(tab) <- paste("P",row.names(tab))

species_ID <- data.frame(species = tab[,"Species"], 
                         ID = rownames(tab))

tab <- tab[, !names(tab) %in% c("Species")]

# Generate dissimilarity matrix
dis <- as.matrix(dist(tab))

# Arbitrarily pick a point (let's say 13) and order a the points in a
# vector with their distance from 13. 

focus <- 13

obj_by_dist <- names(sort(dis[,focus]))

# Create a data frame with columns ord.vector, r, phi, 
# where data is ordered by the ordering vector previously created.
# Set r as the row named as the focus, in the order specified by the
# ordering vector.
# Set the first data point phi to NA, and the second data point 
# phi = pi/2 (arbitrary, looks nice on graph)

plotdata <- data.frame(r = dis[focus, obj_by_dist],
                       phi = NA,
                       row.names =obj_by_dist)
plotdata$phi[1] <- 0
plotdata$phi[2] <- pi/2

# Here we are defining the new_point, the point which we are selecting
# the optimal phi for, as the third point in the obj_by_dist vector 
# (the list of points in order by their distance to the focus point)

new_point <- obj_by_dist[3] 


# Write a function that takes phi as an argument and returns stress.

stress <- function(phi){
  
  # position of the new point, given the candidate phi
  xi <- plotdata[new_point,"r"] * cos(phi)
  yi <- plotdata[new_point,"r"] * sin(phi)
  
  stress = 0
  j = 1                # the iteration variable
  
  while (j < grep(paste("^",new_point,"$",sep=""), obj_by_dist)) {
    # position of each of the previous points, iterating 
    # through the list of previously determined phis
    xj <- plotdata$r[j] * cos(plotdata$phi[j])
    yj <- plotdata$r[j] * sin(plotdata$phi[j])
    
    Dij = sqrt( (xi - xj)^2 + (yi - yj)^2)
    stress = stress + (dis[obj_by_dist[j],new_point] - Dij)^2
    j = j + 1
  }
  return(stress)
}

# pass new_point as a variable, rather than set previously



# Optimize this function using optimize() and and return the optimal 
# phi to the appropriate row in the data table.
# Anchors are necessary, or grep finds multiple IDs there are 
# characters in common.

j <- grep(paste("^",new_point,"$",sep=""), obj_by_dist)

while (j <= length(obj_by_dist)) {
  stress_res <- optimize(stress, c(0,2*pi)) 
  #print( stress_res )
  minvalue <- stress_res$minimum
  plotdata[new_point,"phi"] <- minvalue
  
  phigrid <- seq(0, 2*pi, length.out = 100)
  plot(phigrid,stress(phigrid))
  abline(v = minvalue)
  title(main= paste(new_point, "stress graph"))
  
  j = j + 1
  new_point <- obj_by_dist[j]
}

# Final plot of all values
species_ID <- (species_ID[match(obj_by_dist, species_ID$ID),])

plot((plotdata$r*cos(plotdata$phi)),(plotdata$r*sin(plotdata$phi)), 
     cex=2.5, asp=1, col= species_ID$species )
grid()
text((plotdata$r*cos(plotdata$phi)),(plotdata$r*sin(plotdata$phi)), 
     seq_along(plotdata[,1]) )

# Check the equation for the third point by comparing it to the output of the 
# stressf function.
#thirdphicheck <- acos(((dis[2,3]^2 - 2*dis[1,3]^2)/(-2*dis[1,3]))/plotdata[3,2])

distnet( dis+.1, data.frame( 
  x = plotdata$r*cos(plotdata$phi),
  y = plotdata$r*sin(plotdata$phi) ) )