% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_api.R
\name{setTimeoutAPI}
\alias{setTimeoutAPI}
\title{Change API Timeout}
\usage{
setTimeoutAPI(opts, timeout)
}
\arguments{
\item{opts}{list of simulation parameters returned by the function
\code{\link{setSimulationPathAPI}}}

\item{timeout}{\code{numeric} API timeout (seconds). Default to 60.}
}
\description{
Change API Timeout
}
\examples{
\dontrun{
opts <- setTimeoutAPI(opts, timeout = 45)
}

}
