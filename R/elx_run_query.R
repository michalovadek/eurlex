#' Execute SPARQL queries
#'
#' Executes cURL request to a pre-defined endpoint of the EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries
#'
#' @param query A valid SPARQL query specified by `elx_make_query` or manually
#' @param endpoint SPARQL endpoint
#' @return
#' A data frame containing the results of the SPARQL query.
#' Column `work` contains the Cellar URI of the resource. Rows with even one missing variable are dropped.
#' @export
#' @examples
#' \donttest{
#' elx_run_query(elx_make_query("directive", include_force = TRUE))
#' }

elx_run_query <- function(query = "", endpoint = "http://publications.europa.eu/webapi/rdf/sparql"){

  stopifnot(is.character(query), nchar(query) > 20, grepl("cdm|eurovoc",query))

  curlready <- paste(endpoint,"?query=",gsub("\\+","%2B", utils::URLencode(query, reserved = TRUE)), sep = "")

  sparql_response <- httr::GET(url = curlready,
                               httr::add_headers('Accept' = 'application/sparql-results+xml')
  )

  sparql_response_parsed <- sparql_response %>%
    elx_parse_xml()

  return(sparql_response_parsed)

}

