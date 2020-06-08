#' Execute SPARQL queries
#'
#' Wrapper around SPARQL::SPARQL with pre-defined endpoint of EU Publications Office
#' Relies on elx_make_query to generate valid SPARQL queries
#'
#' @inheritParams elx_make_query
#' @export
#' @examples
#' elx_run_query(resource_type = "directive")

elx_run_query <- function(resource_type, manual_type = ""){

  endpoint <- "http://publications.europa.eu/webapi/rdf/sparql"

  query <- elx_make_query(resource_type = resource_type, manual_type = manual_type)

  sparql_output <- SPARQL(endpoint,query)

  return(sparql_output)

}
