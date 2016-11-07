// This function is written to be used with the focused_mds R htmlWidget

function focused_mds(dis, col_row_names, focus_point) {
    // Initializing variables and defining functions
    function sqr(x) { return x*x}  // Saves a lot of runtime vs Math.pow
    function add(a,b) {return a + b;}
    function repeat(str, num) {return (new Array(num+1)).join(str);}
	var cos = Math.cos
	var sin = Math.sin
	var abs = Math.abs
	
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
	
	// using univariate optimization to calculate the rest
	for(var i = 2; i < names.length; i++) {
		sorted_object[names[i]].phi = optimize_js(0, Math.PI*2, stress, 0.001);
	
		sorted_object[names[i]].x = sorted_object[names[i]].r * cos(sorted_object[names[i]].phi);
		sorted_object[names[i]].y = sorted_object[names[i]].r * sin(sorted_object[names[i]].phi);
	};
	
	return sorted_object;
};
