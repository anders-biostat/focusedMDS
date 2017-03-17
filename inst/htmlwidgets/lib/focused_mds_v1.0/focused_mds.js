// This function is written to be used with the focused_mds R htmlWidget

function focused_mds(distances, ids, focus_point, tol, subsampling) {
    // Initializing variables and defining functions
    function sqr(x) { return x*x};  // Saves a lot of runtime vs Math.pow
	var cos = Math.cos;
	var sin = Math.sin;
	var abs = Math.abs;
	
	// call distances for focus_point
	var focus_dists = distances[ids.indexOf(focus_point)];
	
	// zip together in an array of arrays the names and distances
	var ids_dists = ids.map(function(e,i){
		return [e, focus_dists[i]];
	});
	
	// sort the array by the distances
	ids_dists.sort(function(a,b){
		return a[1] - b[1];
	});
	
	// return index of names in order of distance from focus point 
	var ids_ordered = [];
	for (i in ids_dists){ ids_ordered.push(ids_dists[i][0]); };
	
	// create an indexable object from these sorted ids and distances
	var result = {};
	for(var i=0; i< ids.length; i++) {
		result[ids_dists[i][0]] = {
			r: ids_dists[i][1],
			phi: [],
			x: [],
			y: []
		}
	};
	
// Define the stress function
	// This function, to be optimized on, needs only one input (phi)
	// It finds new_point from the for loop environment defined below
	
	function stress(phi, sample_ids) {
		var stress = 0;
		//position of the new point, given the candidate phi
		var xnew = result[ids_ordered[new_point]].r * cos(phi);
		var ynew = result[ids_ordered[new_point]].r * sin(phi);
	    
		for(j=0; j < new_point; j++ ) {
			//position of the point we are comparing to new point
			var xj = result[ids_ordered[j]].x;
			var yj = result[ids_ordered[j]].y;
	
			//index of column names of matrix, in ORIGINAL order
			var dij_col = ids.indexOf(ids_ordered[new_point]);
			var dij_row = ids.indexOf(ids_ordered[j]);
	
			// actual distance given by dis matrix
			var dij = distances[dij_col][dij_row];
		
			// calculated distance, given where we placed the point
			var Dij = Math.sqrt( sqr((xnew - xj)) + sqr((ynew - yj)) );
	
			var stress = stress + sqr( (dij - Dij));
		};
		return stress;
	};
	
	// setting phi, xy coords, and colors for first two points
	result[ids_ordered[0]].phi = 0;
	result[ids_ordered[0]].x = 0;
	result[ids_ordered[0]].y = 0;

	result[ids_ordered[1]].phi = 3*Math.PI/2;
	result[ids_ordered[1]].x = result[ids_ordered[1]].r * cos(result[ids_ordered[1]].phi);
	result[ids_ordered[1]].y = result[ids_ordered[1]].r * sin(result[ids_ordered[1]].phi);
	
	// use univariate optimization to calculate the rest
	for(var new_point = 2; new_point < ids_ordered.length; new_point++) {
		
		if( ids.length > 100 & subsampling == true & new_point > 100){ 
			
			// For each point after the 100th point, subsample 
			// a fixed n of points to optimize to for each new plotted point
			var npoints = 100
		
			// Randomly choose n points from the ids_ordered list of names from which to subsample to
			var sample_ids = _.sample(ids, npoints) 

			} else { 
			var	sample_ids = ids;
			}
		result[ids_ordered[new_point]].phi = optimize_js(0, Math.PI*2, function(phi){return stress(phi,sample_ids)}, tol);
		result[ids_ordered[new_point]].x = result[ids_ordered[new_point]].r * cos(result[ids_ordered[new_point]].phi);
		result[ids_ordered[new_point]].y = result[ids_ordered[new_point]].r * sin(result[ids_ordered[new_point]].phi);
	};
	return result;
};
