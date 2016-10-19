HTMLWidgets.widget({

  name: 'focusedMDS',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        el.innerText = x.message;

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

HTMLWidgets.widget({
	
	name: "focused_mdsR",
	
	type: "output",
	
	factory: function(el, width, height) {
		
		d3.select(el).html(
			"<body>" +
			"</body>"
		)
	
		var obj = {};
		
		obj.widgetElement = el;
		
		obj.renderValue = function ( x ) {
			
			obj.resize( width, height );
			
			obj.plot = 
			
		}
	
	
	
	
	}
	
	
	
	
	
})