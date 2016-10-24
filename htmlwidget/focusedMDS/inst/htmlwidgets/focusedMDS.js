HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

	// Create object and bind to the element
	  
		  d3.select(el).append("div")
		    .attr("id","chart")

    return {

      renderValue: function(data) {
		  console.log(data.dis)
		  console.log(data.col_row_names)
		  console.log(data.color_array)
		  
		  var result = focused_mds(data.dis, data.col_row_names, data.color_array)
		  
		  el.appendChild(result)
		  
        // TODO: code to render the widget, e.g.


		  
		  

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

