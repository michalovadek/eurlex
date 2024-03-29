% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/elx_label_eurovoc.R
\name{elx_label_eurovoc}
\alias{elx_label_eurovoc}
\title{Label EuroVoc concepts}
\usage{
elx_label_eurovoc(uri_eurovoc = "", alt_labels = FALSE, language = "en")
}
\arguments{
\item{uri_eurovoc}{Character vector with valid EuroVoc URIs}

\item{alt_labels}{If \code{TRUE}, results include comma-separated alternative labels in addition to the preferred label}

\item{language}{Language in which to return the labels, in ISO 639 2-char code}
}
\value{
A \code{tibble} containing EuroVoc unique concept identifiers and labels.
}
\description{
Create a look-up table with labels for EuroVoc concept URIs. Only unique identifiers are returned.
}
\examples{
\donttest{
elx_label_eurovoc(uri_eurovoc = "http://eurovoc.europa.eu/5760", language = "fr")
}
}
