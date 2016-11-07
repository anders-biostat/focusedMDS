Univariate optimization, identical to the R function optimize(). 
Uses a combination of golden section search and successive parabolic
interpolation to find a local minimum.

Translated from Fortran to JS from here :
http://www.netlib.org/fmm/fmin.f (author(s) unstated) 
based on the Algol 60 procedure localmin given in the reference.
Brent, R. (1973) Algorithms for Minimization without Derivatives. 
Englewood Cliffs N.J.: Prentice-Hall.


Usage:
optimize_js(ax, bx, f, tol)

ax: beginning of range to search for a minimum
bx: end of range to search for a minimum
f: your function to optimize
tol: the desired tolerance level

example:

func = function(x, a, b) {
	var result = ax* Math.cos(b);
	return result;
	};

optimize_js(0, Math.PI*2, func, 0.001)

