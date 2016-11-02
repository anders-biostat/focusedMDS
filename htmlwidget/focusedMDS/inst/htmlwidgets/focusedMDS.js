HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(el, width, height) {
	  
	  // This function creates the indexable color_object from the user input of 
	  // an array of names and an array of colors in the same order as those names

	  function createColorObject(col_row_names, color_array){
	  	var color_object = {};
	  	for(var i=0; i < color_array.length; i++) {
	  		color_object[col_row_names[i]] = {
	  			col: color_array[i]
	  		}
	  	};
	  	return color_object;
	  };
	  function sqr(x) { return x*x}  // Saves a lot of runtime vs Math.pow
	  function add(a,b) {return a + b;}
	  function repeat(str, num) {return (new Array(num+1)).join(str);}
		 var cos = Math.cos
		 var sin = Math.sin
	  var abs = Math.abs
	  
	  // Find the bigger, height or width, and set to size, to maintain aspect ratio
	  if(width > height) {
	  	var size = height
	  } else { var size = width}
	  
	  // Initialize objects
	  var old_result = {};
	  var result = {};
	  var x = {};
	  var col_row_names = {};
	  var focus_point = [];
	  var ellipse_coords = {};

    return {

	  renderValue: function(data) {
		     focus_point = data.col_row_names[0]
		     
		     var color_object = createColorObject(data.col_row_names, data.color_array);
			 
		     var result_univ = focused_mds(data.dis, data.col_row_names, data.col_row_names[0])
			 
			 // Find max distance in dis for scaling factor functions
			 var max_array = [];
			 for(var i=0; i< data.dis.length; i++) {
			  	max_array.push(Math.max.apply(null, data.dis[i]))
			 };
			 var max_r = Math.max.apply(null, max_array);

			 var min_array = [];
			 for(var i=0; i< data.dis.length; i++){
			  min_array.push(Math.min.apply(null, data.dis[i]))
			 };
			 var min_r = Math.min.apply(null, min_array);

			 if (abs(min_r) > abs(max_r)) {
			  maxDistance = abs(min_r)
			 } else { maxDistance = max_r}
		  
			 // Create scaling factors
			 x = d3.scaleLinear()
			          .domain([-1*maxDistance, maxDistance])
			          .range([0, size]);
				  
			 // Create svg and append to a div
		     
		     var table = d3.select(el)
				 .append('table')
				 .attr('id', 'table')
					  
			 var chart_container = table.append('tr')
		  
			 var chart = chart_container.append('td')
				 .style('vertical-align','text-top')
			 	 .append('svg:svg')
  			 	 	 .attr('width', size )
			 	 	 .attr('height', size )
			 	 	 .attr('class', 'chart')
			 	 	 .attr('id', 'chart_svg')
					  
			 var main = chart.append('g')
			 	     .attr('width', size)
			 	     .attr('height', size)
			 	     .attr('class', 'main');

			 var g = main.append("svg:g");
			 
			 // Create div for sidebar stuff and append to el
			 
			 var chart_sidebar = chart_container.append('td')
			         .attr('id', 'chart_sidebar')
			       //.attr('width', )
			 
			 var button = chart_sidebar.append('input')
			     .attr()
			 var buttons = chart_sidebar.append('svg')
			     .style('vertical-align','text-top')
			 	     .attr('id', 'buttons')
			 
			 
			 var textButton = buttons.append('rect')
			         .attr('width', 100)
			         .attr('height', 30)
			         .attr('fill', 'cornflowerblue')
			         .on('click', alert('Clicked!'))
			         .text('Show All Text')

			 // Create grid ellipses
			 ellipse_coords = {
				 rx: [ size/8 , size/4 , 3*size/8 , size/2, 5*size/8, 3*size/4 , 7*size/8 , size], 
			 	 ry: [ size/8 , size/4 , 3*size/8 , size/2, 5*size/8, 3*size/4 , 7*size/8 , size]
			 		}
			 
			 

			 g.selectAll("ellipse")
			     .data(data.col_row_names)
			 	.enter().append("ellipse")
			 	     .attr("cx", function(d) {return (result_univ[data.col_row_names[0]]['x'] + size/2 ); })
			         .attr("cy", function(d) {return (result_univ[data.col_row_names[0]]['y'] + size/2 ); })
			         .attr("rx", function(d,i) {return ( ellipse_coords['rx'][i]); })
			         .attr("ry", function(d,i) {return ( ellipse_coords['ry'][i]); })
			 		 .attr("fill", "none")
			 		 .attr("stroke","gray")

			 // Create scatterplot circles with clickable reordering
			 g.selectAll("circle")
			     .data(data.col_row_names)
			     .enter().append("circle")
			 		   .attr("cx", function(d,i) { return x(result_univ[d]['x']); })
			 		   .attr("cy", function(d,i) { return x(result_univ[d]['y']); })
			 		   .attr("r", 0.2 * size/20)
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
			 			   result_univ = focused_mds(data.dis, data.col_row_names, d)
						   result = result_univ
						   focus_point = d
			 			   console.log(d, ' new result_univ:', result_univ)
	   
			 			   // update all circles
			 			   g.selectAll("circle")
			 			       .data(data.col_row_names)
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
			 					   return function(t) { return x( rTween(t) * sin( phiTween(t) ) )}
			 				   })
			 				   .attr("fill", function(d,i) { return color_object[d]['col']})
			 			   	   .attr("stroke", function(d,i) { if(Object.keys(result_univ).indexOf(d) == 0) { return "magenta"}})
	   
			 			   // update text locations
			 			   g.selectAll("text")
			 			   	   .data(data.col_row_names)
			 			       .transition()
			 				   .duration(3000)
			 	  	  		   .attr('x', function(d,i) {return x(result_univ[d]['x'] + 5); })
			 				   .attr('y', function(d,i) {return x(result_univ[d]['y']); })
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
			 	            .data(data.col_row_names)
			 	            .enter()
			 	            .append("text")
			 			    .attr("id",function(d){return "X"+d;})
			 			    .attr("class", "pointlabel");
		
			 // Create text labels	
			 var textLabels = text
			 	  	  		     .attr('x', function(d,i) {return x(result_univ[d]['x'] + 5) ; })
			 					 .attr('y', function(d,i) {return x(result_univ[d]['y']); })
			 					 .text( function (d) {return d })
			 					 .attr("font-family", "sans-serif")
			 					 .attr("font-size", "12px")
			 					 .attr("fill", "black")
			 					 .style("visibility","hidden") 
			result = result_univ 
			col_row_names = data.col_row_names
      },

      resize: function(width, height) {
		  
		  if(width > height) {
		  	var size = height
		  } else { var size = width}
		  
		  ellipse_coords = {
			 rx: [ size/8 , size/4 , 3*size/8 , size/2, 5*size/8, 3*size/4 , 7*size/8 , size], 
		 	 ry: [ size/8 , size/4 , 3*size/8 , size/2, 5*size/8, 3*size/4 , 7*size/8 , size]
		 		}
		  
		  d3.select(el).select("svg")
		    .attr("width", size)
		    .attr("height", size)
		  
		  d3.select(el).select("g")
		    .attr("width", size)
		    .attr("height", size)
		  
		  // update range for scaling factor
		  x.range([0, size]);
		  
		  d3.select('g').selectAll("text")
		  	.attr('x', function(d,i) {return x(result[d]['x'] + 5) ; })
		    .attr('y', function(d,i) {return x(result[d]['y']); })
		  
		  d3.select('g').selectAll("circle")
		    .attr("cx", function(d,i) { return x(result[d]['x']); })
		    .attr("cy", function(d,i) { return x(result[d]['y']); })
		    .attr("r", 0.2 * size/20)
		  
		  d3.select('g').selectAll("ellipse")
		    .attr("cx", function(d) {return (result[focus_point]['x'] + size/2 ); })
			.attr("cy", function(d) {return (result[focus_point]['y'] + size/2 ); })
	        .attr("rx", function(d,i) {return ( ellipse_coords['rx'][i]); })
	        .attr("ry", function(d,i) {return ( ellipse_coords['ry'][i]); })
		  
      }

    };
  }
});

