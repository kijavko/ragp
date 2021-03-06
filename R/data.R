#' 2700 Arabidopsis thaliana protein sequences.
#'
#' A dataset containing the sequences of 2706 Arabidopsis thaliana proteins, with a length of
#' 100 to 400 amino acid residues predicted to contain a N-signal peptide by phobius web server or by SignalP 4.1
#' The dataset represents a cleaned version of all protein sequences obtained from Phytozome V12 as Athaliana_167_TAIR9.fa.gz.
#'
#' @format A data frame with 2706 rows and 4 variables:
#' \describe{
#'   \item{Transcript.id}{TAIR Gene Model id}
#'   \item{sequence}{amino acid sequence of the protein}
#'   \item{is.signalP}{logical, predicted as N-sp by SignalP 4.1}
#'   \item{phobius}{logical, predicted as N-sp by phobius web server}
#' }
#' @source \url{http://genome.jgi.doe.gov/pages/dynamicOrganismDownload.jsf?organism=Phytozome}
"at_nsp"
