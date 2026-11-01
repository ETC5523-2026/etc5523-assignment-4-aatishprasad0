#' Launch the Library rankings explorer app
#'
#' Opens the Shiny app bundled with the package. 
#' 
#' @return Called for its side effect of opening the app in a browser or the
#'   RStudio/Positron viewer. Returns nothing useful.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "overdue")
  if (app_dir == "") {
    stop("App not found. Try reinstalling overdue.", call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}