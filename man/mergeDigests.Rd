% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/digest.R
\name{mergeDigests}
\alias{mergeDigests}
\title{Merge two digests}
\usage{
mergeDigests(digest_new, digest_ori)
}
\arguments{
\item{digest_new}{new digest with missing lines}

\item{digest_ori}{original digest with all lines}
}
\value{
updated digest
list of 5 tables (begin, areas, middle, links lin., links quad.)
}
\description{
Merge two digests
}
\seealso{
\code{\link{readDigestFile}}
}
