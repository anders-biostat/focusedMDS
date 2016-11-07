// This function is written to be used with the focused_mds html file

function focused_mds(dis, col_row_names, color_ids) {

/// Initializing variables and defining functions
function sqr(x) { return x*x}  // Saves a lot of runtime vs Math.pow
var cos = Math.cos
var sin = Math.sin
var abs = Math.abs
function add(a,b) {return a + b;}
function repeat(str, num) {return (new Array(num+1)).join(str);}

// This function creates the indexable color_object from the user input of 
// a table with columns id, color

function createColorObject(color_ids){
	var color_object = {};
	for(var i=0; i < color_ids[0].length; i++) {
		color_object[color_ids[0][i]] = {
			col: color_ids[1][i]
		}
	};
	return color_object;
};

var color_object = createColorObject(color_ids);
console.log(color_object)
// Internal focused MDS function

function focused_mds_int(dis, focus_point) {
	// call distances for focus_point
	var dists = dis[col_row_names.indexOf(focus_point)];
	
	// zip together in an array of arrays the names and distances
	var names_dists = col_row_names.map(function(e,i){
		return [e, dists[i]];
	});
	
	// sort the array by the distances
	names_dists.sort(function(a,b){
		return a[1] - b[1];
	});
	
	// return index of names in order of distance from focus point 
	var names = [];
	for (i in names_dists){ names.push(names_dists[i][0]); };
	
	// create an indexable object from these sorted ids and distances
	var sorted_object = {};
	for(var i=0; i< col_row_names.length; i++) {
		sorted_object[names_dists[i][0]] = {
			r: names_dists[i][1],
			phi: [],
			x: [],
			y: []
		}
	};
	
	// Define the stress function 
	
	function stress(phi) {
		var stress = 0;
		var new_point=i;
		//position of the new point, given the candidate phi
		var xnew = sorted_object[names[new_point]].r * cos(phi);
		var ynew = sorted_object[names[new_point]].r * sin(phi);
	
		for(j=0; j < new_point; j++ ) {
			//position of the point we are comparing to new point
			var xj = sorted_object[names[j]].x;
			var yj = sorted_object[names[j]].y;
		
			//index of column names of matrix, in ORIGINAL order
			var dij_col = col_row_names.indexOf(names[new_point]);
			var dij_row = col_row_names.indexOf(names[j]);
		
			// actual distance given by dis matrix
			var dij = dis[dij_col][dij_row];
			
			// calculated distance, given where we placed the point
			var Dij = Math.sqrt( sqr((xnew - xj)) + sqr((ynew - yj)) );
		
			var stress = stress + sqr( (dij - Dij));
		};
		return stress;
	};
	
	// setting phi, xy coords, and colors for first two points
	sorted_object[names[0]].phi = 0;
	sorted_object[names[0]].x = 0;
	sorted_object[names[0]].y = 0;

	sorted_object[names[1]].phi = 3*Math.PI/2;
	sorted_object[names[1]].x = sorted_object[names[1]].r * cos(sorted_object[names[1]].phi);
	sorted_object[names[1]].y = sorted_object[names[1]].r * sin(sorted_object[names[1]].phi);
	
	// using univariate or multivariate optimization to calculate the rest
	for(var i = 2; i < names.length; i++) {
		sorted_object[names[i]].phi = optimize_js(0, Math.PI*2, stress, 0.001);
	
		sorted_object[names[i]].x = sorted_object[names[i]].r * cos(sorted_object[names[i]].phi);
		sorted_object[names[i]].y = sorted_object[names[i]].r * sin(sorted_object[names[i]].phi);
	};
	
	return sorted_object;
};

var a = performance.now()
var result_univ = focused_mds_int(dis, col_row_names[0])
var b = performance.now()

console.log('Univariate optimization took: ', b-a , ' ms.')
console.log('this is result_univ object:',result_univ)

// Initialize the object to hold the previous phi result, for interpolation
var old_result = {};

/// D3 specifications for plotting

// Set window size and margins
var margin = {top: 90, right: 90, bottom: 90, left: 90}
   , width = 700 - margin.left - margin.right
   , height = 700 - margin.top - margin.bottom;

// Find max distance in dis for scaling factor functions
var max_array = [];
for(var i=0; i< dis.length; i++) {
	max_array.push(Math.max.apply(null, dis[i]))
};
var max_r = Math.max.apply(null, max_array);

var min_array = [];
for(var i=0; i< dis.length; i++){
	min_array.push(Math.min.apply(null, dis[i]))
};
var min_r = Math.min.apply(null, min_array);

if (abs(min_r) > abs(max_r)) {
	maxDistance = abs(min_r)
} else { maxDistance = max_r}

// Create scaling factors
var x = d3.scaleLinear()
          .domain([-1*maxDistance, maxDistance])
          .range([0, width]);

var y = d3.scaleLinear()
		  .domain([-1*maxDistance, maxDistance] )
		  .range([0, height]);

var chart = d3.select('body')
	 .append('svg:svg')
	 .attr('width', width + margin.right + margin.left)
	 .attr('height', height + margin.top + margin.bottom)
	 .attr('class', 'chart');

var main = chart.append('g')
	 .attr('transform','translate(' + margin.left + ',' + margin.top + ')')
	 .attr('width', width)
	 .attr('height', height)
	 .attr('class', 'main');

var g = main.append("svg:g");

// Create grid ellipses
var ellipse_coords = {
	rx: [50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000],
	ry: [50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000]	
}

g.selectAll("ellipse")
    .data(col_row_names)
	.enter().append("ellipse")
	    .attr("cx", function(d) {return (result_univ[col_row_names[0]]['x'] + width/2 ); })
        .attr("cy", function(d) {return (result_univ[col_row_names[0]]['y'] + height/2 ); })
        .attr("rx", function(d,i) {return ( ellipse_coords['rx'][i]); })
        .attr("ry", function(d,i) {return ( ellipse_coords['ry'][i]); })
		.attr("fill", "none")
		.attr("stroke","gray")

// Create scatterplot circles with clickable reordering
g.selectAll("circle")
    .data(col_row_names)
    .enter().append("circle")
		   .attr("cx", function(d,i) { return x(result_univ[d]['x']); })
		   .attr("cy", function(d,i) { return y(result_univ[d]['y']); })
		   .attr("r", 6)
           .attr("fill", function(d,i) { return color_object[d]['col']})
		   .attr("stroke", function(d,i) { if(Object.keys(result_univ).indexOf(d) == 0) { return "magenta"}})  
		   .on( "dblclick", function(d,i) {
			  
			   //rerun focused MDS, find new maxDistance
			   console.log( "You have clicked on point " + d)
			   
			   // save phis from previous result for arc transition
			   old_result = {};
			   for(var i=0; i< Object.keys(result_univ).length; i++){
				   old_result[Object.keys(result_univ)[i]] = {
					   phi: result_univ[Object.keys(result_univ)[i]].phi,
					   r: result_univ[Object.keys(result_univ)[i]].r
			   }}
			   
			   // update result_univ object by rerunning focused_mds
			   result_univ = focused_mds_int(dis, d)
			   console.log(d, ' new result_univ:', result_univ)
			   
			   // update all circles
			   g.selectAll("circle")
			       .data(col_row_names)
			       .transition()
			       .duration(3000)
			       .attrTween("cx", function(d,i) {
					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result_univ[d].phi] )
					   var rTween = d3.scaleLinear().range( [old_result[d].r, result_univ[d].r] )
					   return function(t) { return x( rTween(t) * cos( phiTween(t) ) )}
				   })
				   .attrTween("cy", function(d,i) {
					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result_univ[d].phi] )
					   var rTween = d3.scaleLinear().range( [old_result[d].r, result_univ[d].r] )
					   return function(t) { return y( rTween(t) * sin( phiTween(t) ) )}
				   })
				   .attr("fill", function(d,i) { return color_object[d]['col']})
			   	   .attr("stroke", function(d,i) { if(Object.keys(result_univ).indexOf(d) == 0) { return "magenta"}})
			   
			   // update text locations
			   g.selectAll("text")
			   	   .data(col_row_names)
			       .transition()
				   .duration(3000)
	  	  		   .attr('x', function(d,i) {return x(result_univ[d]['x'] + 5); })
				   .attr('y', function(d,i) {return y(result_univ[d]['y']); })
				   .text( function (d) {return d })
			   
		 	 })
			 
			 .on("mouseover", function(d){
  			     d3.select("text#X"+d)	 	 
				     .style("visibility","visible")
		     })
	         .on("mouseout", function(d){
 			     d3.select("text#X"+d)
			  	     .style("visibility","hidden")
		     })
		     ;
			 
// Add svg text element to g
var text = g.selectAll("text")
	            .data(col_row_names)
	            .enter()
	            .append("text")
			    .attr("id",function(d){return "X"+d;})
			    .attr("class", "pointlabel");
				
// Create text labels	
var textLabels = text
	  	  		     .attr('x', function(d,i) {return x(result_univ[d]['x'] + 5) ; })
					 .attr('y', function(d,i) {return y(result_univ[d]['y']); })
					 .text( function (d) {return d })
					 .attr("font-family", "sans-serif")
					 .attr("font-size", "12px")
					 .attr("fill", "black")
					 .style("visibility","hidden")

return g

};
		