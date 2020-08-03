#' Execute SPARQL queries
#'
#' Executes cURL request to a pre-defined endpoint of the EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries
#'
#' @param query A valid SPARQL query specified by `elx_make_query` or manually
#' @param endpoint SPARQL endpoint
#' @export
#' @examples
#' \donttest{
#' elx_run_query(elx_make_query("directive", include_force = TRUE))
#' }

elx_run_query <- function(query = "", endpoint = "http://publications.europa.eu/webapi/rdf/sparql"){

  stopifnot(is.character(query), nchar(query) > 20, grepl("cdm|consilium|eurovoc",query))

  if (grepl("data.consilium",query)){

    endpoint <- "https://data.consilium.europa.eu/sparql"

  }

  curlready <- paste(endpoint,"?query=",gsub("\\+","%2B", utils::URLencode(query, reserved = TRUE)), sep = "")

  sparql_response <- RCurl::getURL(url = curlready)

  sparql_response_parsed <- elx_parse_xml(sparql_response)

  return(sparql_response_parsed)

}
