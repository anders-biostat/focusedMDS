# Optimize() translated into Javascript

# This is a translation of the R function optimize() from the original Fortran code given by the optimize() annotation
#  http://www.netlib.org/fmm/fmin.f (author(s) unstated)
# based on the Algol 60 procedure localmin in 
# Brent, R. (1973) Algorithms for Minimization without Derivatives. Englewood Cliffs N.J.: Prentice-Hall.

# This is an R implementation of the function, to make sure it is working correctly,
# before translating it again to javascript. Should be the same syntax except for 
# variable definition and 'continue' is the same as 'next' in R.

f <- function(x){ cos(x) + sin(x)}

# Initial parameter definition

optimize_js <- function(ax, bx, f, tol){
  # the squared inverse of the golden ratio
  c = 0.5 * (3.0 - sqrt(5.0)) 
  
  # eps is approximately the square root of the relative machine precision
  eps = 1.0
  tol1 = 1.0 + eps
  while (tol1 > 1.0) {   
    eps = eps/2.0
    tol1 = 1.0 + eps
  }
  eps = sqrt(eps)
  
  # initialization of variables 
  a = ax
  b = bx
  v = a + c*(b-a)
  w = v
  x = v
  e = 0
  fx = f(x)
  fv = fx
  fw = fx
  # main loop
  while(TRUE) {
    xm = 0.5*(a+b)
    tol1 = eps * abs(x) + tol/3.0
    tol2 = 2.0 * tol1
    
    #check stopping criterion
    if (abs(x - xm) <= (tol2 - 0.5*(b-a))){
      fmin = x
      break
    }
    
    # if necessary, perform golden section step to get d
    if(abs(e) <= tol1){       
      if(x >= xm) {e = a-x
      } else {e = b-x}
      d = c*e
      
      # else fit parabola
    } else {                  
      r = (x - w)*(fx - fv)
      q = (x - v)*(fx - fw)
      p = (x - v)*q - (x - w)*r
      q = 2.0*(q - r)
      if(q > 0) {p = -p}
      q = abs(q)
      r = e
      e = d
      
      # If parabola is acceptable, perform golden section step to get d
      if (abs(p) >= abs(0.5*q*r) | p <= q*(a-x) | p >= q*(b-x)){ 
        if(x >= xm) {e = a-x
        } else {e = b-x}
        d = c*e
        
        # else do parabolic interpolation to get d
      } else {
        d = p/q
        u = x + d
        # f must not be evaluated too close to ax or bx
        if( (u-a) < tol2 ) {d = tol1 * sign(xm-x)}
        if( (b-u) < tol2 ) {d = tol1 * sign(xm-x)} 
      } 
    }
    
    # f must not be evaluated too close to x
    if (abs(d) >= tol1) { u = x+d 
    } else { u = x + tol1*sign(d) }
    fu = f(u)
    
    # update values for a, b, v, w, and x, return to top
    if (fu > fx) {
      if (u < x) { a = u 
      } else { b = u }
      if (fu <= fw | w == x){
        v = w
        fv = fw
        w = u
        fw =fu
        #print("The problem is at B")
        next
      } else if (fu <= fv | v == x | v == w){
        v = u
        fv = fu
        #print("The problem is at C")
        next
      }
    } else {
      if( u >= x) { a=x 
      } else { b=x }
      v = w
      fv = fw
      w = x
      fw = fx
      x = u
      fx = fu
      #print("The problem is at D")
      next
    }
  }
  return(fmin)
}

solution <- optimize_js(0, 2*pi, f, 0.001)

pdat <- data.frame( x=seq(0, 2*pi, length.out = 100),
            y= NA)
pdat$y <- lapply(pdat$x, f)

plot(pdat$x, pdat$y)

### Run the focused_mds function with this optimization, see if you get the same results 
focused_mds2 <- function(m, focus) {
  
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
    stress_res <- optimize_js(stress, c(0,2*pi))
    minvalue <- stress_res
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

result2 <- focused_mds(dis,focus)

## Compare results
par(mfrow=c(1,2))
plot(result$xcoord, result$ycoord, main="Optimize() Results")
plot(result2$xcoord, result2$ycoord, main= "optimize_js Results")

result$phi == result$phi

# Yes!!!