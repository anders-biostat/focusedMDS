var nlopt = requires('nlopt');

var myfunc = function(n, x, grad){
  if(grad){
    grad[0] = 0.0;
    grad[1] = 0.5 / Math.sqrt(x[1]);
  }
  return Math.sqrt(x[1]);
}

var createMyConstraint = function(cd){
  return {
    callback:function(n, x, grad){
      if(grad){
        grad[0] = 3.0 * cd[0] * (cd[0]*x[0] + cd[1]) * (cd[0]*x[0] + cd[1])
        grad[1] = -1.0
      }
      tmp = cd[0]*x[0] + cd[1]
      return tmp * tmp * tmp - x[1]
    },
    tolerance:1e-8
  }
}

options = {
  algorithm: "LD_MMA",
  numberOfParameters:2,
  minObjectiveFunction: myfunc,
  inequalityConstraints:[createMyConstraint([2.0, 0.0]), createMyConstraint([-1.0, 1.0])],
  xToleranceRelative:1e-4,
  initalGuess:[1.234, 5.678],
  lowerBounds:[Number.MIN_VALUE, 0]
}

console.log(nlopt(options).parameterValues);




