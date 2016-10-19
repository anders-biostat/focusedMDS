#' @import htmlwidgets
#' @export

focused_mds <- function(dis, col_row_names= NULL, color_ids = NULL) {
	# input the data and save as the object names that js needs
	
	if( !is.matrix(dis) )
		stop( "'dis' must be a square matrix or 'dist' object.")
	
	if( nrow(dis) != ncol(dis))
		stop( "Distance matrix 'dis' is not square.")
	
	if( is.null(col_row_names))
		col_row_names <- seq(1, nrow(dis))
	
	if( nrow(dis) != length(col_row_names))
		stop( "Number of rows in 'dis' does not match length of 'col_row_names' array.")
	
	if( !is.null(color_ids))
		color_ids <- rep("black", nrow(dis))
	
	if( nrow(dis) != nrow(color_ids))
		stop( "Number of rows in 'dis' does not match number of rows in 'color_ids' table.")
	
	htmlwidgets::createWidget ("focused_mds",
	list(dis=dis, col_row_names= col_row_names, color_ids= color_ids))

}
