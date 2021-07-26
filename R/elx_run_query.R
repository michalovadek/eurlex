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

  sparql_response <- graceful_http(curlready)

  sparql_response_parsed <- sparql_response %>%
    elx_parse_xml()

  return(sparql_response_parsed)

}

#' Fail http call gracefully
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

graceful_http <- function(remote_file) {

  try_GET <- function(x, ...) {
    tryCatch(
      httr::GET(url = x,
                #httr::timeout(1000000000),
                httr::add_headers('Accept' = 'application/sparql-results+xml')),
      error = function(e) conditionMessage(e),
      warning = function(w) conditionMessage(w)
    )
  }

  is_response <- function(x) {
    class(x) == "response"
  }

  # First check internet connection
  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  # Then try for timeout problems
  resp <- try_GET(remote_file)
  if (!is_response(resp)) {
    message(resp)
    return(invisible(NULL))
  }

  # Then stop if status > 400
  if (httr::http_error(resp)) {
    httr::message_for_status(resp)
    return(invisible(NULL))
  }

  return(resp)

}

