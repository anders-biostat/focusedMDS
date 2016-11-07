#' focusedMDS
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export


focusedMDS <- function(dis, col_row_names= NULL, color_array = NULL, size= NULL)  {
  
  # Run through some if statements to check the input data
  
  if( !is.matrix(dis) )
  	stop( "'dis' must be a square matrix or 'dist' object.")

  if( is.null(col_row_names))
  	col_row_names <- seq(1, nrow(dis))

  if( nrow(dis) != length(col_row_names))
  	stop( "Number of rows in 'dis' does not match length of 'col_row_names' array.")

  if( nrow(dis) != length(color_array))
  	stop( "Number of rows in 'dis' does not match length of 'color_ids' array.")
  
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
