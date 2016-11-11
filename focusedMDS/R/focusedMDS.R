#' focusedMDS
#' 
#' <Focused, interactive multidimensional scaling>
#'
#' @import htmlwidgets
#'
#' @export

focusedMDS <- function(distances, ids = NULL, colors = NULL, focus_point = ids[1],
	                   size = NULL, circles = 7, tol = 0.001 )  {
  
  # Run through some if statements to check the input data
  graph <- TRUE
  
  if( class(distances) == "dist") {
	  distances <- as.matrix(distances)
  } 
  
  if( !is.matrix(distances)) {
	 stop( "'distances' must be a matrix or 'dist' object.")
  }
  
  if( nrow(distances) != ncol(distances))
	stop( "'distances' must be a square matrix or 'dist' object.")
 
  
  if( is.null(ids))  {
	  ids <- c(1:nrow(distances))
  } else {
	  if( nrow(distances) != length(ids)) {
	  	stop( "Number of rows/columns in 'distances' does not match length of 'ids' vector.")
	  }
  }

  if( is.null(colors) ) {
	  colors <- rainbow(nrow(distances), v = .85)
	  } else {
		  if(nrow(distances) != length(colors) ) {
		  	stop( "Number of rows/columns in 'distances' does not match length of 'colors' vector.")
	  }
  }
  
  if( !is.numeric(tol)) {
	  stop("'tol' must be numeric ")
  }
  
  if( !is.null(size)) {
	  if( !is.numeric(size)) {
		  stop("'size' must be numeric (px).")
	  }
  }
  
  circles <- circles * 2 
  
  # create a list that contains the data to feed to JSON
  data = list(
    distances = distances, ids = ids, colors = colors, tol = tol, 
	focus_point = focus_point, graph = graph, circles = circles
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'focusedMDS',
    data,
	height = size,
	width = size,
    package = 'focusedMDS'
  )
}
