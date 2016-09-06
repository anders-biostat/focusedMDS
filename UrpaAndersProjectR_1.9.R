# Solutions to the mathematical portion of the project in R
# Lea Urpa, Simon Anders rotation in FIMM-EMBL PhD 
library(distnetR)

## Interesting data so far:
##    - AML patient gene expression data, when patients distances are calculated only with top 10 most variable genes
##        -> two easily identified clusters
##    - AML voom expression of gene expression in response to drugs
##        -> interesting outliers

## AML data

# Gene expression for each patient.

    #load("/Users/admin/Documents/Rotation1_AndersLab/Expr.entID.expressed.rda")  
    #tab <- Expr.entID
    #row.names(tab) <- Expr.entID$Sample
    #tab <- tab[, !names(tab) %in% c("Sample")]

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

tab_var <- apply(tab, 2, var)
top_10 <- names(tail(sort(tab_var),10))
tab <- tab[, c(top_10)]


dis <- as.matrix(dist(tab))

# Focused MDS function, where the input is the matrix and the point clicked by the user

focused_mds <- function(m, focus) {
  
  obj_by_dist <- names(sort(dis[,focus]))  # sort points by distance to focus
  
  plotdata <- data.frame(r = dis[focus, obj_by_dist],  # order df by dist to focus
                         phi = NA,
                         row.names =obj_by_dist)
  
  plotdata$phi[1] <- 0         # To set focus at origin
  plotdata$phi[2] <- pi/2      # To set 2nd point on y axis
  
  stress <- function(phi){
    
    # position of the new point, given the candidate phi
    xnew <- plotdata[new_point,"r"] * cos(phi)
    ynew <- plotdata[new_point,"r"] * sin(phi)
    
    stress = 0
    j = 1                # the iteration variable
    
    # position of each of the previous points, iterating through the list of previously determined phis
    
    while (j < which(new_point == obj_by_dist)) {   
      
      xj <- plotdata$r[j] * cos(plotdata$phi[j])
      yj <- plotdata$r[j] * sin(plotdata$phi[j])
      
      Dij = sqrt( (xnew - xj)^2 + (ynew - yj)^2)
      stress = stress + (dis[obj_by_dist[j],new_point] - Dij)^2
      j = j + 1
    }
    return(stress)
  }
  
  new_point <- obj_by_dist[3]  # We begin optimizing on the third point
  
  k <- which(new_point == obj_by_dist)          # the numerical position of new_point in obj_by_dist
  
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
