HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

	// Create object and bind to the element
	  
		  d3.select(el).append("div")
		    .attr("id","chart_container")
	  
		//  d3.select(chart)
		//	.append('svg')
	     // .attr('width', size)
		 // .attr('height', size)
		//	.attr('id', 'main')
	  

    return {

      renderValue: function(data) {
		  console.log(data.dis)
		  console.log(data.col_row_names)
		  console.log(data.color_array)
		  
		  focused_mds(data.dis, data.col_row_names, data.color_array);
		  
		  
		  var removed = d3.select("chart_svg").remove()
		  
		  d3.select(chart_container).append( function() {
		  	return removed.node()
		  })
		  
        // TODO: code to render the widget, e.g.


		  
		  

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

