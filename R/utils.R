#' Rescale standardised variable
#'
#' @param x Numeric vector to be rescaled
#' @param mean Numeric value indicating the mean of the original vector
#' @param sd Numeric value indicating the standard deviation of the original vector
rescale_variable <- function(x, mean, sd) {
    (x * sd) + mean
}