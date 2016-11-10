#' focusedMDS
#' FIXME add description
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export

# FIXME add input for user to generate xy coords to R instead of graph
focusedMDS <- function(distances, ids = NULL, colors = NULL, graph = YES, tol = 0.001 )  {
  
  # Run through some if statements to check the input data
  
  # FIXME this so that if input is a dist object, convert to matrix
  if( !is.matrix(distances) )
    stop( "distances object must be a square matrix or 'dist' object.")

  if( nrow(distances) != ncol(distances))
	stop( "distances object must be a square matrix or 'dist' object.")
  
  if( is.null(ids))
  	ids <- c(1:nrow(distances))

  if( nrow(distances) != length(ids))
  	stop( "Number of rows/columns in 'dis' does not match length of 'col_row_names' vector.")

  if( nrow(distances) != length(colors))
  	stop( "Number of rows/columns in 'dis' does not match length of 'colors' vector.")
  
  # create a list that contains the data to feed to JSON
  data = list(
    distances = distances, ids = ids, colors = colors, graph = graph
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'focusedMDS',
    data,
    package = 'focusedMDS'
  )
}
