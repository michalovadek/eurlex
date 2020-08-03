#' Label EuroVoc concepts
#'
#' Create a look-up table with labels for EuroVoc concept URIs. Only unique identifiers are returned.
#'
#' @param uri_eurovoc Character vector with valid EuroVoc URIs
#' @param alt_labels If `TRUE`, results include comma-separated alternative labels in addition to the preferred label
#' @param language Language in which to return the labels, in ISO 639 2-char code
#' @export
#' @examples
#' elx_label_eurovoc(uri_eurovoc = "http://eurovoc.europa.eu/5760", alt_labels = TRUE, language = "fr")
#' elx_label_eurovoc(uri_eurovoc = c("http://eurovoc.europa.eu/5760","http://eurovoc.europa.eu/576"))


elx_label_eurovoc <- function(uri_eurovoc = "", alt_labels = FALSE, language = "en"){

  uri_eurovoc <- paste0(paste("<",unique(uri_eurovoc),">", sep = ""), collapse = " ")

  getlabs <- "skos:prefLabel"

  if (alt_labels == TRUE){
    getlabs <- "skos:prefLabel skos:altLabel"
  }

  query <- paste("PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
  SELECT DISTINCT (group_concat(distinct ?subject;separator=',') as ?eurovoc)
  (group_concat(distinct ?label;separator=',') as ?labels)
  from <http://eurovoc.europa.eu/100141>
  where{
  VALUES ?subject { ",
                 uri_eurovoc,
  " }",
  "VALUES ?searchLang { '",
                 language,
  "' undef }
  VALUES ?relation { ",
                 getlabs,
  "}
  ?subject a skos:Concept .
  ?subject ?relation ?label .
  filter ( lang(?label)=?searchLang )
  } GROUP BY ?subject",
                 sep = "")

  out <- elx_run_query(query)

  return(out)

}

