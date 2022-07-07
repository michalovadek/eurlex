#' Execute SPARQL queries
#'
#' Executes cURL request to a pre-defined endpoint of the EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries.
#' Results are capped at 1 million rows.
#'
#' @param query A valid SPARQL query specified by `elx_make_query()` or manually
#' @param endpoint SPARQL endpoint
#' @return
#' A data frame containing the results of the SPARQL query.
#' Column `work` contains the Cellar URI of the resource.
#' @export
#' @examples
#' \donttest{
#' elx_run_query(elx_make_query("directive", include_force = TRUE))
#' }

elx_run_query <- function(query = "", endpoint = "http://publications.europa.eu/webapi/rdf/sparql"){

  stopifnot(is.character(query), nchar(query) > 20, grepl("cdm|eurovoc", query))

  curlready <- paste(endpoint,"?query=",gsub("\\+","%2B", utils::URLencode(query, reserved = TRUE)), sep = "")

  sparql_response <- graceful_http(curlready,
                                   headers = httr::add_headers('Accept' = 'application/sparql-results+xml'),
                                   verb = "GET")

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

graceful_http <- function(remote_file, headers, verb = c("GET","HEAD")) {

  try_GET <- function(x, ...) {
    tryCatch(
      httr::GET(url = x,
                #httr::timeout(1000000000),
                #httr::add_headers('Accept' = 'application/sparql-results+xml'),
                headers),
      error = function(e) conditionMessage(e),
      warning = function(w) conditionMessage(w)
    )
  }
  
  try_HEAD <- function(x, ...) {
    tryCatch(
      httr::HEAD(url = x,
                #httr::timeout(1000000000),
                #httr::add_headers('Accept' = 'application/sparql-results+xml'),
                headers),
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
  
  if (verb == "GET"){
    
    # Then try for timeout problems
    resp <- try_GET(remote_file)
    if (!is_response(resp)) {
      message(resp)
      return(invisible(NULL))
    } 
    
  }
  
  else if (verb == "HEAD"){
    
    # Then try for timeout problems
    resp <- try_HEAD(remote_file)
    if (!is_response(resp)) {
      message(resp)
      return(invisible(NULL))
    } 
    
  }

  # Then stop if status > 400
  if (httr::http_error(resp)) {
    httr::message_for_status(resp)
    return(invisible(NULL))
  }

  return(resp)

}

#' Parse RDF/XML triplets to data frame
#' An internal function to parse RDF/XML output from SPARQL queries.
#'
#' @noRd
#' @importFrom rlang .data
#'

elx_parse_xml <- function(sparql_response = ""){

  res_binding <- sparql_response %>% 
    xml2::read_xml() %>% 
    xml2::xml_find_all("//d1:binding")

  res_text <- xml2::xml_text(res_binding) 

  res_cols <- xml2::xml_attr(res_binding, "name")

  if (identical(unique(res_cols), c("eurovoc","labels"))){ # for use in elx_label_eurovoc

    out <- data.frame(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="eurovoc", T, NA)) %>%
      dplyr::group_by(.data$is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(.data$is_work==T, .data$triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(.data$triplet) %>%
      dplyr::select(-.data$is_work) %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-.data$triplet)

  } else {

    out <- data.frame(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="work", T, NA)) %>%
      dplyr::group_by(.data$is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(.data$is_work==T, .data$triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(.data$triplet) %>%
      dplyr::select(-.data$is_work) %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-.data$triplet)

  }

  return(out)

}
