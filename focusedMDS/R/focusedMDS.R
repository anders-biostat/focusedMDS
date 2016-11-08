#' focusedMDS
#' FIXME add description
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export

# FIXME add input for user to generate xy coords to R instead of graph
focusedMDS <- function(dis, col_row_names= NULL, colors = NULL )  {
  
  # Run through some if statements to check the input data
  
  # FIXME this so that if input is a dist object, convert to matrix
  if( !is.matrix(dis) )
	  # FIXME also add a check to make sure it's square
  	stop( "'dis' must be a square matrix or 'dist' object.")

  if( is.null(col_row_names))
  	col_row_names <- 1, nrow(dis)

  if( nrow(dis) != length(col_row_names))
  	stop( "Number of rows/columns in 'dis' does not match length of 'col_row_names' vector.")

  if( nrow(dis) != length(colors))
  	stop( "Number of rows/columns in 'dis' does not match length of 'colors' vector.")
  
  # create a list that contains the data to feed to JSON
  data = list(
    dis = dis, col_row_names = col_row_names, color_array = color_array
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'focusedMDS',
    data,
    width = size,
    height = size,
    package = 'focusedMDS'
  )
}
