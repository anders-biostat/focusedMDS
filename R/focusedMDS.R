#' Focused, interactive multidimensional scaling
#' 
#' \code{focusedMDS} takes a distance matrix and plots
#' it as an interactive graph. Double click on
#' any point to choose a new focus point, and hover over
#' points to see their ID labels. In this graph, one point 
#' is focused on at the center of the graph. All other points
#' are plotted around this central point at their exact 
#' distances to the point, as given in the distance matrix.
#' In other words, the distance between each point and the
#' focus point are the true distances given in the distance 
#' matrix. The non focus points are plotted with respect to 
#' each other as exactly as possible. For more details, see
#' \url{https://lea-urpa.github.io/focusedMDS.html}.
#'
#' @import htmlwidgets
#' @importFrom "grDevices" "rainbow"
#' @importFrom "grDevices" "col2rgb"
#'
#' @export
#'
#' 
#' @param distances A square, symmetric distance matrix or 
#'   \code{dist} object. 
#' @param ids A vector with length equal to the 
#'   number of rows of the matrix given in \code{distances}.
#'   Must be a character vector.
#' @param color_cat A vector with length equal to the
#'   number of rows of the matrix given in \code{distances}.
#'   Content of the vector can be either numeric, factor, or 
#'   character. Values will be assigned to color categories.
#' @param focus_point The initial ID to be plotted at the
#'   center of the focusedMDS graph (default is the first 
#'   element in the \code{ids} vector). Must be an element of
#'   the \code{ids} vector.
#' @param size The fixed size of the focusedMDS graph, in 
#'   pixels. Disables dynamic sizing.
#' @param circles The number of background polar gridlines.
#' @param tol The tolerance for the optimization method choosing
#'   the location of the non-focus points. Default 0.001.
#' @param color_palette Optional specification of a color palette to use
#'   when \code{colors} parameter is given. Must be a vector of CSS colors, 
#'   with length at least as long as the number of unique variables in
#'   \code{colors}.
#' @param check_matrix Logical value permitting additional checks of the matrix,
#'   ensuring that the given matrix fulfills the
#'   triangle inequality. Slows down the initial graph plotting, 
#'   but useful if you are not sure if your matrix is a distance
#'   matrix or has been calculated correctly.
#' @param subsampling Logical value stating that for samples of over
#'   100 points, each point iteratively plotted after the 100th point will 
#'   be optimized to a subsample of the previously plotted data points.
#'   Recommended for plotting data sets with more than 300 points.
#' 
#' @examples
#' # See http://lea-urpa.github.io/focusedMDS.html for 
#' # an illustrated version of this example.
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
#' colors <- c("firebrick", "cornflowerblue", "gold")
#'
#' # Visualization with color labels
#' focusedMDS(dists, color_cat = colorvector, color_palette = colors )
#'
#' # Create text labels
#' table(iris$Species)
#' names <- c(paste(rep("setosa", 50), 1:50, sep=""),
#'            paste(rep("versicolor", 50), 1:50, sep=""),
#'            paste(rep("virginica", 50), 1:50, sep=""))
#'
#' focusedMDS(dists, ids = names, color_cat = colorvector, color_palette = colors)
#'
#'
#'


focusedMDS <- function(distances, ids = NULL, color_cat = NULL, focus_point = ids[1],
	                   size = NULL, circles = 7, tol = 0.001, check_matrix = FALSE,
					   subsampling = FALSE, color_palette = NULL )  {
  
  # Define function that converts hex/named colors to rgb
  toRGBvector <- function(colorsvector) {
	  rgbcolors <- as.data.frame(t(col2rgb(colorsvector)))
	  rgbcolors <- paste(rgbcolors$red, rgbcolors$green, rgbcolors$blue, sep = ",")
	  rgbvector <- paste(rep("rgb(", length(rgbcolors)), rgbcolors, rep(")", length(rgbcolors)), sep= "")
  }
  
  # Run through some if statements to check the input data
  graph <- TRUE
  
  # Convert dist object to matrix, if necessary
  if( class(distances) == "dist") {
	  distances <- as.matrix(distances)
	  check_matrix <- FALSE
  } 
  
  # Check that the input is a matrix
  if( !is.matrix(distances)) {
	 stop( "'distances' must be a matrix or 'dist' object.")
  }
  
  # Check that the matrix is square
  if( nrow(distances) != ncol(distances))
	stop( "'distances' must be a square matrix or 'dist' object.")
  
  # Check that the matrix is symmetric
  
  if( is.element(FALSE, distances == t(distances)) ){
	  stop("Matrix does not appear to be symmetric. Are you sure it's a distance matrix? Try submitting a dist object.")
  }
  
  # Check that the matrix fulfills the triangle inequality.
  if(check_matrix == TRUE){
	  for(i in 1:nrow(distances)){
	    for(j in 1:nrow(distances)){
	      for(k in 1:nrow(distances)){
	        if(i==j | i==k | j==k){
      
	        } else if( (round(distances[i,j], digits=2) <= 
							round(distances[i,k] + distances[j,k], digits=2)) == FALSE |
	                   (round(distances[i,k], digits=2) <= 
					   	 	round(distances[i,j] + distances[j,k], digits=2)) == FALSE |
	                   (round(distances[j,k], digits=2) <= 
					   		round(distances[i,j] + distances[i,k], digits=2)) == FALSE ){
	          stop("Matrix does not fulfill triangle inequality. Are you sure it's a distance matrix? Try submitting a dist object.")
	        } 
	      }
	    }
	  }
  }
  
  # If no IDs specified, add ID vector. 
  # If IDs specified, confirm the vector is of the correct length and is a character vector, and has no duplicates
  if( is.null(ids))  {
	  ids <- paste( rep("N", nrow(distances)), c(1:nrow(distances)), sep = "")
  } else {
	  if( nrow(distances) != length(ids)) {
	  	stop( "Number of rows/columns in 'distances' does not match length of 'ids' vector.")
	  }
	  if( class(ids) != "character"){
		stop( "ids vector is not a character vector.")
	  }
	  if( length(unique(ids)) != length(ids)){
		stop( "ids vector contains duplicate names. Please ensure all ids are unique")
	  }
  }
  
  # Check that the specified focus_point is contained in the ids vector
  if( any(ids == focus_point) == FALSE) {
	  stop("Given focus_point is not an element in the ids vector.")
  }
  
  # Check that color_palette is at least as long as the number of unique variables in color_cat
  if(!is.null(color_palette)){
	  if( length(color_palette) < length(unique(color_cat))){
		  stop( "'color_palette' must be at least as long as the number of unique variables (categories) in the 'color_cat' vector")
	  }
  }
  
  # If no colors specified, give rainbow colors.
  if( is.null(color_cat) ) {
	  colors <- rainbow(nrow(distances), v = .70)
	  
	  # If no colors vector given, set legend_data value to false
	  legend_data = list( categories = rep("__nolegend__", 3), colors = rep("__nolegend__", 3))
	  
	  } else {
		  # If colors specified, check that the number of colors matches the number of points.
		  if(nrow(distances) != length(color_cat) ) {
		  	stop( "Number of rows/columns in 'distances' does not match length of 'color_cat' vector.")
	  	  }
		  # Assign colors based on categories given in 'colors' vector
		  categories <- as.character(unique(color_cat))
		  colors <- as.character(color_cat) # copying color_cat vector

		  if(is.null(color_palette)){
			  # Assign rainbow colors if none others given
		  	  uniqueColors <- rainbow(length(unique(colors)), v = .70) 
		  } else {
			  # Use color_palette if given
			  uniqueColors <- color_palette[1:length(unique(colors))]
		  }
		  
		  for(i in 1:length(uniqueColors)){
			  colors[colors == categories[i]]  <- uniqueColors[i]
		  }
		  # Convert uniqueColors to RBG
		  uniqueColors <- toRGBvector(uniqueColors)
		  legend_data <- list( categories = categories, colors = uniqueColors )	   
  }
  
  # Convert colors to rgb colors
  colors <- toRGBvector(colors) 
  
  # Check that that tolerance level is given as a number
  if( !is.numeric(tol)) {
	  stop("'tol' must be numeric ")
  }
  
  # Check that the size of the window is given as a number
  if( !is.null(size)) {
	  if( !is.numeric(size)) {
		  stop("'size' must be numeric (px).")
	  }
  }
  
  circles <- circles * 2 
  
  # create a list that contains the data to feed to JSON
  data = list(
    distances = distances, ids = ids, colors = colors, tol = tol, 
	focus_point = focus_point, graph = graph, circles = circles,
	subsampling = subsampling, legend_data = legend_data
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
