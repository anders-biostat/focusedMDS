#bfgs-numericjs

optimisation with bfgs, implemented using [numericjs] (http://www.numericjs.com)

##use:

```js
numeric.bfgs(guess,objective,maxIter,eps,opt);
```

guess: an array with your initial guess

objective: an object with two attribute, 'f' your function to optimise and 'df' your derivative

maxIter: number of iteration before to stop

eps: if the norm of the gradient is below this level, stop

opt: an optional argument with the following atributes:

-maxTry: number of try in the linesearch step before to stop (default: 25)

-c1: 1st wolfe condition parameter (default: 0.25)

-c2: 2nd wolfe condition parameter (default: 0.75) 

##example


```js
function sqr(x){ return x*x; };
function f(arg){
  var x = arg[0];
  var y = arg[1];
  return sqr(10*(y-x*x)) + sqr(1-x);
}

function df(arg){
  var ret = [];
  var x = arg[0];
  var y = arg[1];
  var tmp = 200*(y-x*x);
  ret[0] = -2*x*tmp - 2*(1-x)
  ret[1] = tmp;
  return ret;
}

var ret = bfgs([0,0],{f:f,df:df},1000,10e-16);
```
