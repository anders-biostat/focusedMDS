HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(g, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
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

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

