Names of variables: distances, colors, ids, graph

HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(el, width, height) {
	  
	  function sqr(x) { return x*x}  // Saves a lot of runtime vs Math.pow
	  function add(a,b) {return a + b;}
	  function repeat(str, num) {return (new Array(num+1)).join(str);}
	  var cos = Math.cos
	  var sin = Math.sin
	  var abs = Math.abs
	  
	  // Find the bigger, height or width, and set to size, to maintain aspect ratio
	  var size = width > height ? width : height
	  
	  //FIXME make sure you need all these
	  // Initialize objects
	  var old_result = {};
	  var result = {};
	  var scale = {};
	  var element_ids = {};
	  var focus_point = "__none__";
	  var ellipse_coords = {};
	  var sliderPosition = null;

    return {

	  renderValue: function(data) {
		     focus_point = data.ids[0]
		     
	 	  	 var color_object = {};
	 	  	 for(var i=0; i < colors.length; i++) {
	 	  	 	 color_object[ids[i]] = colors[i]
	 	  	 };
			 
		     var result = focused_mds(data.distances, data.ids, focus_point, data.tol)
			 
			 // Find max distance in dist for scaling factor functions
			 var maxDistance = [];
			 
			 for(var i=0; i< data.distances.length; i++) {
			 	 for(j=0; j< data.distances.length; j++){
					 if( maxDistance < distances[i][j]){
					 	maxDistance = distances[i][j]
					 }
				 }
			 };
		  
			 // Create scaling factors
			 scale = d3.scaleLinear()
			          .domain([-1*maxDistance, maxDistance])
			          .range([0, size]);
				  
			 // Create svg and append to a div
					  
			 var chart_container = d3.select(el)
				 .append('div')
			     .attr('id', 'chart_container')
				 //.style('position')
		  
			 var chart = chart_container.append('svg:svg')
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
			 
			 var chart_inset = d3.select(el)
			      .append('div')
			      .style('position', 'absolute')
			      .style('top', '0')
			      .style('left', '0')
				     .attr('id', 'chart_inset')
			         .attr('height', 61)
			         .attr('width', 140)
			 
			 var chart_background = chart_inset.append('svg')
			      .style('position', 'relative')
			      .style('z-index', 1)
			      .style('top', '0')
			      .style('left', '0')
			         .attr('height', 61)
			         .attr('width', 140)
			 
			 chart_background.append('rect')
			      .attr('fill', 'white')
			      .attr('height', 61)
			      .attr('width', 140)
			 
			 var button_div = chart_inset.append('div')
			      .style('text-align', 'left')
			      .style('position', 'absolute')
			      .style('z-index', 2)
			      .style('top', 0)
			      .style('left', 0)
			 
			 var button = button_div.append('input')
			     //.style('vertical-align', 'top')
				     .attr('type', 'checkbox')
			         .property('checked', false)
			 
			 chart_inset.select('input').on('change', function(d){ 
				 if (button.property('checked') == true) { 
					 g.selectAll('text')
					     .style('visibility', 'visible')
				 } else { 
					 g.selectAll('text')
			 			 .style('visibility', 'hidden')
			 	 }
			 })
			 
			 var text = button_div.append('text')
			     .text(' Show all labels')
			     .style('font-family', 'Georgia, serif')
			     .style('font-size', '14px')
			 
			 
			 var slider_div = chart_inset.append('div')
			     .style('text-align', 'center')
			      .style('position', 'absolute')
			      .style('z-index', 2)
			      .style('top', '20px')
			      .style('left', 0)
			 
			 slider_div.append('text')
			     .text('Circle size:')
			     .style('font-family', 'Georgia, serif')
			     .style('font-size', '14px')
			 
			 
			 var sliderContainer = slider_div.append('svg')
			     .attr('height',20)
			     .attr('width', 140)
			 
			 var slider = sliderContainer.append('g')
			     .attr('class', 'slider')
			     .attr('width', 150)
			 
			 slider.append('line')
			           .attr('class', 'track')
			           .attr('y1', 10)
			           .attr('y2', 10)
			           .attr('x1', 10)
			           .attr('x2', 130)
			           .style('stroke-linecap', 'round')
			           .style('stroke-opacity', 0.3)
			           .style('stroke-width', '8px')
			           .style('stroke', '#000')
			     .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
			           .attr('class', 'track-inset')
			           .style('stroke-linecap', 'round')
			           .style('stroke', '#ddd')
			           .style('stroke-width', '6px')
			     .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
			           .attr('class', 'track-overlay')
			           .style('stroke-linecap','round')
			           .style('pointer-events', 'stroke')
			           .style('stroke-width', '20px')
			           .style('cursor', 'crosshair')
			           .call(d3.drag()
		                       .on('start.interrupt', function() { slider.interrupt(); })
		 				       .on('start.drag', function() { sizeAdjust(d3.event.x); }))
			 
			 var handle = slider.insert('circle', '.track-overlay')
			           .attr('class','handle')
			           .attr('r', 5)
			           .attr('cx', 65)
			           .attr('cy', 10)
			           .style('fill', '#fff')
			           .style('stroke', '#000')
			           .style('stroke-opacity', '0.5')
			           .style('stroke-width', '1.25px')	
			 
			 function sizeAdjust(input) {
				 if(input < 10){
				 	handle.attr('cx', 10)
				 } else if(input > 130){
				 	handle.attr('cx', 130)
				 } else {
				 	handle.attr('cx', input)
				 };
				 
				 g.selectAll('circle')
				     .attr('r', 0.2 * size/20 * input/65 );
				 
				 sliderPosition = input;
			 }	 

			 // Create polar coordinate gridline radii
			 gridlines_rs = [];
			 for(var i=1; i != 9; ++i) { gridlines_rs.push(i/8 *size) }
			 
			 g.selectAll("ellipse")
			 	.enter().append("circle")
					 .attr("id", "polar_gridlines")
			 	     .attr("cx", function() {return (result[data.ids[0]]['x'] + size/2 ); })
			         .attr("cy", function() {return (result[data.ids[0]]['y'] + size/2 ); })
			         .attr("r", function(i) {return ( gridlines_rs[i]); })
			 		 .attr("fill", "none")
			 		 .attr("stroke","gray")
			 
			 // Create scatterplot circles with clickable reordering
			 g.selectAll("circle")
			     .data(data.ids)
			     .enter().append("circle")
					   .attr("id", "data_points")
			 		   .attr("cx", function(d,i) { return scale(result[d]['x']); })
			 		   .attr("cy", function(d,i) { return scale(result[d]['y']); })
			 		   .attr("r", function() {console.log(0.2 * size/20); return 0.2 * size/20; })
			           .attr("fill", function(d,i) { return color_object[d]['col']})
			 		   .attr("stroke", function(d,i) { if(Object.keys(result).indexOf(d) == 0) { return "red"}})  
			 		   .on( "dblclick", function(d,i) {
			 			   // save phis from previous result for arc transition
			 			   old_result = {};
			 			   for(var i=0; i< Object.keys(result).length; i++){
			 				   old_result[Object.keys(result)[i]] = {
			 					   phi: result[Object.keys(result)[i]].phi,
			 					   r: result[Object.keys(result)[i]].r
			 			   }}
	   
			 			   // update result_univ object by rerunning focused_mds
			 			   result = focused_mds(data.distances, data.ids, d)
						   focus_point = d
	   
			 			   // update all circles
			 			   g.selectAll("#data_points")
			 			       .data(data.ids)
			 			       .transition()
			 			       .duration(3000)
			 			       .attrTween("cx", function(d,i) {
			 					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result[d].phi] )
			 					   var rTween = d3.scaleLinear().range( [old_result[d].r, result[d].r] )
			 					   return function(t) { return scale( rTween(t) * cos( phiTween(t) ) )}
			 				   })
			 				   .attrTween("cy", function(d,i) {
			 					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result[d].phi] )
			 					   var rTween = d3.scaleLinear().range( [old_result[d].r, result[d].r] )
			 					   return function(t) { return scale( rTween(t) * sin( phiTween(t) ) )}
			 				   })
			 				   .attr("fill", function(d,i) { return color_object[d]['col']})
			 			   	   .attr("stroke", function(d,i) { if(Object.keys(result).indexOf(d) == 0) { return "red"}})
	   
			 			   // update text locations
			 			   g.selectAll("#textLabels")
			 			   	   .data(data.ids)
			 			       .transition()
			 				   .duration(3000)
			 			       .attrTween("x", function(d,i) {
			 					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result[d].phi] )
			 					   var rTween = d3.scaleLinear().range( [old_result[d].r, result[d].r] )
			 					   return function(t) { return scale( rTween(t) * cos( phiTween(t) ) + 5)}
			 				   })
			 				   .attrTween("y", function(d,i) {
			 					   var phiTween = d3.scaleLinear().range( [old_result[d].phi, result[d].phi] )
			 					   var rTween = d3.scaleLinear().range( [old_result[d].r, result[d].r] )
			 					   return function(t) { return scale( rTween(t) * sin( phiTween(t) ) )}
			 				   })
			 				   .text( function (d) {return d })
	   
			 		 	 })
	 
			 			 .on("mouseover", function(d){
			   			     d3.select("text#X"+d)	 	 
			 				     .style("visibility","visible")
			 		     })
			 	         .on("mouseout", function(d){
							 if( button.property('checked') == false ){
			  			         d3.select("text#X"+d)
			 			  	         .style("visibility","hidden")
							 } 
			 		     })
			 		     ;
	 
			 // Add svg text element to g
			 var text = g.selectAll("text")
			 	            .data(data.ids)
			 	            .enter()
			 	            .append("text")
			 			    .attr("id",function(d){return "X"+d;})
			 			    .attr("class", "pointlabel")
						    .attr("id","textLabels")
		
			 // Create text labels	
			 var textLabels = text
			 	  	  		     .attr('x', function(d,i) {return scale(result[d]['x'] + 5) ; })
			 					 .attr('y', function(d,i) {return scale(result[d]['y']); })
			 					 .text( function (d) {return d })
			 					 .attr("font-family", "sans-serif")
			 					 .attr("font-size", "12px")
			 					 .attr("fill", "black")
			 					 .style("visibility","hidden") 
      },

      resize: function(width, height) {
		  
		  var size = width > height ? width : height;
		  
		  gridlines_rs = [];
		  for(var i=1; i != 9; ++i) { gridlines_rs.push(i/8 *size) }
		  
		  d3.select(el).select("svg")
		    .attr("width", size)
		    .attr("height", size)
		  
		  d3.select(el).select("g")
		    .attr("width", size)
		    .attr("height", size)
		  
		  // update range for scaling factor
		  scale.range([0, size]);
		  
		  d3.select('g').selectAll("text")
		  	.attr('x', function(d,i) {return scale(result[d]['x'] + 5) ; })
		    .attr('y', function(d,i) {return scale(result[d]['y']); })
		  console.log(sliderPosition)
		  d3.select('g').selectAll("#data_points")
		    .attr("cx", function(d,i) { return scale(result[d]['x']); })
		    .attr("cy", function(d,i) { return scale(result[d]['y']); })
		    .attr("r", function() { if(sliderPosition == null) { console.log(0.2 * size/20); return 0.2 * size/20 } 
		    else { console.log(0.2 * size/20 * sliderPosition/65 ); return 0.2 * size/20 * sliderPosition/65 } })
		  
		  d3.select('g').selectAll("#polar_gridlines")
		    .attr("cx", function(d) {return (result[focus_point]['x'] + size/2 ); })
			.attr("cy", function(d) {return (result[focus_point]['y'] + size/2 ); })
	        .attr("r", function(d,i) {return ( gridlines_rs[i]); })
		  
      }

    };
  }
});

