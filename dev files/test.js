require( "numeric" );

var f = function( x ) {
  return (x[0]-2)*(x[0]-2)+x[0]*x[0]*x[0]*x[0];
}

var g = function( x ) {
  return [ 2*(x[0]-2) + 4*x[0]*x[0]*x[0] ];
}


var res = numeric.uncmin( f, [3], g );

console.log( res );