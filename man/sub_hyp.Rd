% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/internal_hyp.R
\name{sub_hyp}
\alias{sub_hyp}
\title{Substitute prolines to hydroxyprolines}
\usage{
sub_hyp(sequence, id, hyp)
}
\arguments{
\item{sequence}{protein sequences in the form of a string vector}

\item{id}{protein ids in the form of a string vector}

\item{hyp}{the prediction object returned by predict_hyp}
}
\value{
A vector of strings where P are changed to O based on predict_hyp prediction
}
\description{
This function substitutes P with O based on predict_hyp prediction
}
\note{
This is an internal function used inside predict_hyp
}
\seealso{
\code{\link[ragp]{predict_hyp}}
}
