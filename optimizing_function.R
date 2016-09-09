## Optimizing focused_mds function for large datasets
library(RcppDE)

## DSS data

# Correlation coefficients for genes and drugs, calculated over all patients

load("/Users/admin/Documents/Rotation1_AndersLab/corr.exp.dss.rda")      
tab <- corr.exp.dss[,!names(corr.exp.dss) %in% c("Genetype","Symbol","Entrez","Ensembl")]
tab <- t(tab)

# Getting columns with top 10 variance calculations, generate dissimilarity matrix

tab_var <- apply(tab, 2, var)
top_10 <- names(tail(sort(tab_var),10))
tab <- tab[, c(top_10)]


dis <- as.matrix(dist(tab))


## Focused MDS function

## Current try: for a fixed phi (no optimization step), store x and y values (no calculating cos and sin)
## Taking out the optimization step gives half time, but incorrect values
## Storing x and y values, and not recalculating using cos and sin during stress calculation, halves time!!
## Comparing squared distances, rather than actual distances NOPE this gives wrong stress values

focused_mds_optim <- function(m, focus) {
  
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
  result <<- plotdata
}
# Set focus to 1

focus <- 1

# Run focused mds

focused_mds_optim(dis,focus)

# Plot results

plot((result$r*cos(result$phi)), (result$r*sin(result$phi)),
     #xlim =c(), ylim= c(),
     cex=1, asp=1 )
plot(result[,"xcoord"], result[,"ycoord"], cex=1, asp=1)
grid()


### Writing the stress function as a derivative, and finding the zero points of that question mark???

## I'm a bit lost as to how to use the derivative, or another optimization function that uses a derivative.

## Code profiling...
Rprof(filename="fmds_Rprof.out")
focused_mds(dis,focus)
Rprof(NULL)
summaryRprof("fmds_Rprof.out")

##This one was a good try but it's actually a LOT slower
#DEoptim_stress <- DEoptim(stress, lower= 0, upper=2*pi,
#                          control = DEoptim.control(
#                            trace = F,
#                            itermax = 5
#                          ))
#minvalue <- as.numeric(DEoptim_stress$optim$bestmem)



