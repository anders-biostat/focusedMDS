# Optimize() translated into Javascript

# This is a translation of the R function optimize() from the original Fortran code given by the optimize() annotation
#  http://www.netlib.org/fmm/fmin.f (author(s) unstated)
# based on the Algol 60 procedure localmin in 
# Brent, R. (1973) Algorithms for Minimization without Derivatives. Englewood Cliffs N.J.: Prentice-Hall.

# This is an R implementation of the function, to make sure it is working correctly,
# before translating it again to javascript. Should be the same syntax except for 
# variable definition and 'continue' is the same as 'next' in R.

f <- function(x){ 3 + 2*x + x^8}

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
  
  # defining a function to perform the golden section step
 # golden_section_step = function(x,xm,a,b,c){
#    if(x >= xm) {e = a-x}
#    else {e = b-x}
#    d = c*e
#    return(e) # couldn't figure out how to properly return d and e, so let's just repeat 4 lines of code.
#    return(d)
#  }
  
  # main loop
  while(TRUE) {
    xm = 0.5*(a+b)
    tol1 = eps * abs(x) + tol/3.0
    tol2 = 2.0 * tol1
    
    #check stopping criterion
    if (abs(x - xm) <= (tol2 - 0.5(b-a))){
      fmin = x
      break
    }
    
    # if necessary, perform golden section step
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
      
      # If parabola is acceptable, perform golden section step
      if (abs(p) >= abs(0.5*q*r) | p <= q*(a-x) | p >= q*(b-x)){ 
        if(x >= xm) {e = a-x
        } else {e = b-x}
        d = c*e
        
        # else do parabolic interpolation
      } else {
        d = p/q
        u = x + d
        if( (u-a) < tol2 ) {d = tol1 * sign(xm-x)}
        if( (b-u) < tol2 ) {d = tol1 * sign(xm-x)} 
      } 
    }
  }
  
  
  
}

