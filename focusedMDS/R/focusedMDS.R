#' Focused, interactive multidimensional scaling
#' 
#' \code{focusedMDS} takes a distance matrix and 
#' outputs an htmlwidget interactive graph where 
#' a chosen point is 'focused' at the center of 
#' the graph. The points are plotted with exact
#' distance to the focus point, meaning the values 
#' given in the distance matrix, while the non-focus
#' points are plotted as exactly as possible to one
#' another. See \url{https://lea-urpa.github.io/focusedMDS.html} 
#' for more details.
#'
#' @import htmlwidgets
#'
#' @export
#'

#' 
#' @param distances A square, symmetric matrix or 
#'   \code{dist} object.
#' @param ids A vector with length equal to the 
#'   number of rows of the matrix given in \code{distances}.
#'   Must be a character vector.
#' @param colors A vector with length equal to the
#'   number of rows of the matrix given in \code{distances}.
#'   Must be CSS colors, or they will display as black.
#' @param focus_point The initial ID to be plotted at the
#'   center of the focusedMDS graph (default is the first 
#'   element in the \code{ids} vector). Must be an element of
#'   the \code{ids} vector.
#' @param size The fixed size of the focusedMDS graph, in 
#'   pixels. Disables dynamic sizing.
#' @param circles The number of background polar gridlines.
#' @param tol The tolerance for the optimization method choosing
#'   the location of the non-focus points. Default 0.001.
#' 
#' @examples
#' See \{https://lea-urpa.github.io/focusedMDS.html} for 
#' an illustrated version of this example.
#'
#' library(datasets)
#' library(focusedMDS)
#' 
#' # Load Edgar Anderson's Iris Data
#' data("iris")
#'
#' # Create table of measures to compare individuals on
#' table <- iris[ , c("Petal.Length", "Petal.Width", "Sepal.Length", "Sepal.Width")]
#'
#' # Find euclidean distances based on these measures
#' dists <- dist(table)
#'
#' # Simplest usage: only with dataset
#' focusedMDS(dists)
#'
#' # Create labels based on flower species
#' colorvector <- as.vector(iris$Species)
#'
#' colorvector[colorvector == "setosa"] <- "firebrick"
#' colorvector[colorvector == "versicolor"] <- "cornflowerblue"
#' colorvector[colorvector == "virginica"] <- "gold"
#'
#' # Visualization with color labels
#' focusedMDS(dists, colors = colorvector )
#'
#' # Create text labels
#' table(iris$Species)
#' names <- c(paste(rep("setosa", 50), 1:50, sep=""),
#'            paste(rep("versicolor", 50), 1:50, sep=""),
#'            paste(rep("virginica", 50), 1:50, sep=""))
#'
#' focusedMDS(dists, ids = names, colors = colorvector)
#'
#'
#'


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
	  ids <- paste( rep("N", nrow(distances)), c(1:nrow(distances)), sep = "")
  } else {
	  if( nrow(distances) != length(ids)) {
	  	stop( "Number of rows/columns in 'distances' does not match length of 'ids' vector.")
	  }
	  if( class(ids != "character")){
		stop( "ids vector is not a character vector.")
	  }
  }
  
  if( match(focus_point, ids) == NA) {
	  stop("Given focus_point is not an element in the ids vector.")
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
