HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(svgElement, width, height) {

    // TODO: define shared variables for this instance

	// Create object and bind to the element
	  
		  d3.select(svgElement).append("div")
		    .attr("id","chart")

    return {

      renderValue: function(x) {
		  console.log(x.dis)
		  console.log(x.col_row_names)
		  console.log(x.color_ids)
		  focused_mds(x.dis, x.col_row_names, x.color_ids)
		  
        // TODO: code to render the widget, e.g.


		  
		  

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

