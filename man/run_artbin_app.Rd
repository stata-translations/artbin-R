\name{run_artbin_app}
\alias{run_artbin_app}
\title{Launch the artbin Shiny Application}
\description{
Opens a browser-based graphical interface for the \code{\link{artbin}}
function. The app allows interactive specification of all artbin parameters
and displays the R code that reproduces the selected calculation.
}
\usage{
run_artbin_app()
}
\details{
The application requires the \pkg{shiny} package. It is launched using
\code{shiny::runApp()} and will open in the system default browser.
}
\examples{
\dontrun{
  run_artbin_app()
}
}
