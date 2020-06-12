#' Execute SPARQL queries
#'
#' Wrapper around SPARQL::SPARQL with pre-defined endpoint of EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries
#'
#' @inheritParams elx_make_query
#' @param query Defaults to "preset" corresponding to one of resource_type; paste custom SPARQL query to override
#' @export
#' @examples
#' elx_run_query(resource_type = "directive")

elx_run_query <- function(resource_type, manual_type = "", query = "preset"){

  endpoint <- "http://publications.europa.eu/webapi/rdf/sparql"

  if (query == "preset"){

    query <- elx_make_query(resource_type = resource_type, manual_type = manual_type)

  }

  if (query != "preset"){

    query <- query

  }

  sparql_response <- SPARQL(endpoint,query)

  return(sparql_response)

}
