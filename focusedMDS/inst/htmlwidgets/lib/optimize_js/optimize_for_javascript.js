// A function translated from Fortran to JS from here :
// http://www.netlib.org/fmm/fmin.f (author(s) unstated) 
// based on the Algol 60 procedure localmin given in the reference.
// Brent, R. (1973) Algorithms for Minimization without Derivatives. 
// Englewood Cliffs N.J.: Prentice-Hall.


// An approximation x to the point where f attains a minimum on
// the interval (ax,bx) is determined

// input:

// ax    left endpoint of the initial interval
// bx    right endpoint of the initial interval
// f     function subprogram which evalues f(x) for any x 
//       in the interval (ax, bx)
// tol   desired length of the interval of uncertainty of the final
//       result (eg 0.0d0)

// output:

// fmin abcissa approximating the point where f attains a minimum

//     the method used is a combination of  golden  section  search  and
//  successive parabolic interpolation.  convergence is never much slower
//  than  that  for  a  fibonacci search.  if  f  has a continuous second
//  derivative which is positive at the minimum (which is not  at  ax  or
//  bx),  then  convergence  is  superlinear, and usually of the order of
//  about  1.324....
//      the function  f  is never evaluated at two points closer together
//  than  eps*abs(fmin) + (tol/3), where eps is  approximately the square
//  root  of  the  relative  machine  precision.   if   f   is a unimodal
//  function and the computed values of   f   are  always  unimodal  when
//  separated by at least  eps*abs(x) + (tol/3), then  fmin  approximates
//  the abcissa of the global minimum of  f  on the interval  ax,bx  with
//  an error less than  3*eps*abs(fmin) + tol.  if   f   is not unimodal,
//  then fmin may approximate a local, but perhaps non-global, minimum to
//  the same accuracy.
//      this function subprogram is a slightly modified  version  of  the
//  algol  60 procedure  localmin  given in richard brent, algorithms for
//  minimization without derivatives, prentice - hall, inc. (1973).
	
var optimize_js = function(ax, bx, f, tol) {
	
	// c is the squared inverse of the golden ratio
	var c = 0.5 * (3.0 - Math.sqrt(5.0));
	
    // eps is approximately the square root of the relative machine
    // precision.
	var eps = 1.0;
	var tol1 = 1.0 + eps;
	while (tol1 > 1.0){
		eps = eps/2.0;
		tol1 = 1.0 + eps;
	}
	eps = Math.sqrt(eps);
	
	// Initialization of variables
  	var a = ax;
  	var b = bx;
  	var v = a + c*(b-a);
  	var w = v;
  	var x = v;
  	var e = 0;
  	var fx = f(x);
  	var fv = fx;
  	var fw = fx;
	
	// Main loop
	MainLoop:
	while (true){
   	 	var xm = 0.5*(a+b);
    	var tol1 = eps * Math.abs(x) + tol/3.0;
    	var tol2 = 2.0 * tol1;
		
		// Check if stopping criterion
	    if (Math.abs(x - xm) <= (tol2 - 0.5*(b-a))){
			var fmin = x;
			break MainLoop;
	    }
		
		// If necessary, perform golden section step to get d
	    if(Math.abs(e) <= tol1){       
	      if(x >= xm) {
			  var e = a - x;
	      } else {
			  var e = b - x;
		  }
	      var d = c*e;
		
		// else fit parabola
	  	} else {
	  	  	var r = (x - w)*(fx - fv);
	        var q = (x - v)*(fx - fw);
	        var p = (x - v)*q - (x - w)*r;
	        var q = 2.0*(q - r);
	        if(q > 0) {
				var p = -1*p;
			}
	        var q = Math.abs(q);
	        var r = e;
	        var e = d;
			
			// If parabola is acceptable, perform golden section step to get d
	        if (Math.abs(p) >= Math.abs(0.5*q*r) | p <= q*(a-x) | p >= q*(b-x)){ 
	          if(x >= xm) {
				  var e = a-x;
	          } else {
				  var e = b-x;
			  }
	          var d = c*e;
			  
			  // else do parabolic interpolation to get d
		  } else {
			  var d = p/q;
			  var u = x + d;
	        
			//f must not be evaluated too close to ax or bx
	        if( (u-a) < tol2 ) { 
				var d = tol1 * Math.sign(xm-x);
			}
	        if( (b-u) < tol2 ) { 
				var d = tol1 * Math.sign(xm-x);
			} 
		  }
	  	}
		
		// f must not be evaluated too close to x
	    if (Math.abs(d) >= tol1) { 
			var u = x+d; 
	       } else { 
			   var u = x + tol1 * Math.sign(d);
		   }
	       var fu = f(u);
		
		// update values for a, b, v, w, and x, return to top
		   if (fu > fx) {
		        if (u < x) { 
					var a = u; 
		        } else { 
					var b = u;
				}
		        if (fu <= fw | w == x){
					var v = w;
					var fv = fw;
					var w = u;
					var fw =fu;
					continue MainLoop;
					
		        } else if (fu <= fv | v == x | v == w){
					var v = u;
					var fv = fu;
					continue MainLoop;
		        }
				
		      } else {
		        if( u >= x) {
					var a=x; 
		        } else {
					var b=x; 
				}
					var v = w;
					var fv = fw;
					var w = x;
					var fw = fx;
					var x = u;
					var fx = fu;
					continue MainLoop;
		      }
	} // while loop end tag	
	return fmin;
} //function end bracket











