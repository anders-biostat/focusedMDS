HTMLWidgets.widget({

  name: 'testWidget',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        //el.innerText = x.message;
		
		var text = document.createElement("div")
		text.innerText = x.message
		el.appendChild(text)
		
		var svg = document.createElementNS(  "http://www.w3.org/2000/svg", "rect" )
		svg.setAttribute("width", 700)
		svg.setAttribute("height", 700)
		svg.setAttribute("class", "chart")
		
		var g = document.createElementNS( "http://www.w3.org/2000/svg", "rect" )
		g.setAttribute("x", 100)
		g.setAttribute("y", 100)
		g.setAttribute("width", 500)
		g.setAttribute("height", 500)
		g.setAttribute("fill", "gray")
		svg.appendChild(g);	
		el.appendChild(svg);
		
		//g.addEventListener("dblclick", function(){ alert("Heya!"); });
		
		d3.select("svg").append( "circle" )
		.attr( "r", 30 )
		.attr("cx", 100)
		.attr("cy", 100);
		d3.select(g).on( "dblclick", function(){ alert("Heya!"); })
		
		
		
		//var text = document.createTextNode(message);
		//div1.appendChild(text);
		
	

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});