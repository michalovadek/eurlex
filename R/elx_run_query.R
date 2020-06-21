#' Execute SPARQL queries
#'
#' Wrapper around SPARQL::SPARQL with pre-defined endpoint of EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries
#'
#' @param query A valid SPARQL query specified by `elx_make_query` or manually
#' @export
#' @examples
#' elx_run_query(resource_type = "directive")

elx_run_query <- function(query = ""){

  endpoint <- "http://publications.europa.eu/webapi/rdf/sparql"

  stopifnot(is.character(query), nchar(query) > 20, grepl("cdm",query))

  sparql_response <- SPARQL(endpoint,query)

  return(sparql_response$results %>% dplyr::mutate_all(~stringr::str_remove_all(.,"<|>")))

}
