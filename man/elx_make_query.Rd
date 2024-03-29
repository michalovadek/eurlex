% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/elx_make_query.R
\name{elx_make_query}
\alias{elx_make_query}
\title{Create SPARQL queries}
\usage{
elx_make_query(
  resource_type = c("any", "directive", "regulation", "decision", "recommendation",
    "intagr", "caselaw", "manual", "proposal", "national_impl"),
  manual_type = "",
  directory = NULL,
  sector = NULL,
  include_corrigenda = FALSE,
  include_celex = TRUE,
  include_lbs = FALSE,
  include_date = FALSE,
  include_date_force = FALSE,
  include_date_endvalid = FALSE,
  include_date_transpos = FALSE,
  include_date_lodged = FALSE,
  include_force = FALSE,
  include_eurovoc = FALSE,
  include_citations = FALSE,
  include_citations_detailed = FALSE,
  include_author = FALSE,
  include_directory = FALSE,
  include_directory_code = FALSE,
  include_sector = FALSE,
  include_ecli = FALSE,
  include_court_procedure = FALSE,
  include_judge_rapporteur = FALSE,
  include_advocate_general = FALSE,
  include_court_formation = FALSE,
  include_court_scholarship = FALSE,
  include_court_origin = FALSE,
  include_original_language = FALSE,
  include_proposal = FALSE,
  order = FALSE,
  limit = NULL
)
}
\arguments{
\item{resource_type}{Type of resource to be retrieved via SPARQL query}

\item{manual_type}{Define manually the type of resource to be retrieved}

\item{directory}{Restrict the results to a given directory code}

\item{sector}{Restrict the results to a given sector code}

\item{include_corrigenda}{If \code{TRUE}, results include corrigenda}

\item{include_celex}{If \code{TRUE}, results include CELEX identifier for each resource URI}

\item{include_lbs}{If \code{TRUE}, results include legal bases of legislation}

\item{include_date}{If \code{TRUE}, results include document date}

\item{include_date_force}{If \code{TRUE}, results include date of entry into force}

\item{include_date_endvalid}{If \code{TRUE}, results include date of end of validity}

\item{include_date_transpos}{If \code{TRUE}, results include date of transposition deadline for directives}

\item{include_date_lodged}{If \code{TRUE}, results include date a court case was lodged with the court}

\item{include_force}{If \code{TRUE}, results include whether legislation is in force}

\item{include_eurovoc}{If \code{TRUE}, results include EuroVoc descriptors of subject matter}

\item{include_citations}{If \code{TRUE}, results include citations (CELEX-labelled)}

\item{include_citations_detailed}{If \code{TRUE}, results include citations (CELEX-labelled) with additional details}

\item{include_author}{If \code{TRUE}, results include document author(s)}

\item{include_directory}{If \code{TRUE}, results include the label of the Eur-Lex directory code}

\item{include_directory_code}{If \code{TRUE}, results include the Eur-Lex directory code}

\item{include_sector}{If \code{TRUE}, results include the Eur-Lex sector code}

\item{include_ecli}{If \code{TRUE}, results include the ECLI identifier for court documents}

\item{include_court_procedure}{If \code{TRUE}, results include type of court procedure and outcome}

\item{include_judge_rapporteur}{If \code{TRUE}, results include the Judge-Rapporteur}

\item{include_advocate_general}{If \code{TRUE}, results include the Advocate General}

\item{include_court_formation}{If \code{TRUE}, results include the court formation}

\item{include_court_scholarship}{If \code{TRUE}, results include court-curated relevant scholarship}

\item{include_court_origin}{If \code{TRUE}, results include country of origin of court case}

\item{include_original_language}{If \code{TRUE}, results include authentic language of document (usually case)}

\item{include_proposal}{If \code{TRUE}, results include the CELEX of the proposal of the adopted legal act}

\item{order}{Order results by ids}

\item{limit}{Limit the number of results, for testing purposes mainly}
}
\value{
A character string containing the SPARQL query
}
\description{
Generates pre-defined or manual SPARQL queries to retrieve document ids from Cellar.
List of available resource types: http://publications.europa.eu/resource/authority/resource-type .
Note that not all resource types are compatible with default parameter values.
}
\examples{
elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE)
elx_make_query(resource_type = "regulation", include_corrigenda = TRUE, order = TRUE)
elx_make_query(resource_type = "any", sector = 2)
elx_make_query(resource_type = "manual", manual_type = "SWD")
}
