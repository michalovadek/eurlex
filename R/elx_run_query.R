#' Execute SPARQL queries
#'
#' Executes cURL request to a pre-defined endpoint of the EU Publications Office.
#' Relies on elx_make_query to generate valid SPARQL queries.
#' Results are capped at 1 million rows.
#'
#' @param query A valid SPARQL query specified by [elx_make_query()] or manually
#' @param endpoint SPARQL endpoint
#' @return
#' A data frame containing the results of the SPARQL query.
#' Column `work` contains the Cellar URI of the resource.
#' @export
#' @examples
#' \donttest{
#' elx_run_query(elx_make_query("directive", include_force = TRUE, limit = 10))
#' }

elx_run_query <- function(query = "", endpoint = "http://publications.europa.eu/webapi/rdf/sparql"){

  # stopping criteria
  stopifnot(is.character(query), nchar(query) > 20, grepl("cdm|eurovoc", query))
  
  # url encoding
  curlready <- paste(endpoint,"?query=",gsub("\\+","%2B", utils::URLencode(query, reserved = TRUE)), sep = "")

  # http call
  sparql_response <- graceful_http(curlready,
                                   headers = httr::add_headers('Accept' = 'application/sparql-results+xml'),
                                   verb = "GET")
  
  # if var created, continue
  if (!is.null(sparql_response)){
    
    # parse response
    sparql_response_parsed <- sparql_response %>% 
      elx_parse_xml()
    
  } else {return(invisible(NULL))}

  # return
  return(sparql_response_parsed)

}

#' Fail http call gracefully
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

graceful_http <- function(remote_file, headers = NULL, body = NULL, 
                          verb = c("GET", "HEAD", "POST"), timeout = 100000, 
                          content_type = NULL, encode = NULL) {
  
  # Check internet connection
  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }
  
  # Make the HTTP request based on the verb
  make_request <- function(verb) {
    tryCatch({
      if (verb == "GET") {
        httr::GET(url = remote_file, config = httr::timeout(timeout), headers)
      } else if (verb == "HEAD") {
        httr::HEAD(url = remote_file, config = httr::timeout(timeout), headers)
      } else if (verb == "POST") {
        httr::POST(url = remote_file, body = body, headers, 
                   content_type = content_type, encode = encode)
      }
    },
    error = function(e) {
      message("Error: ", conditionMessage(e))
      return(invisible(NULL))
    },
    warning = function(w) {
      message("Warning: ", conditionMessage(w))
      return(invisible(NULL))
    })
  }
  
  # Execute the request
  resp <- make_request(verb)
  
  # Check for HTTP errors
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

elx_parse_xml <- function(sparql_response = "", strip_uri = TRUE){

  # process XML response
  res_binding <- sparql_response %>% 
    xml2::read_xml() %>% 
    xml2::xml_find_all("//d1:binding")

  res_text <- xml2::xml_text(res_binding) 

  res_cols <- xml2::xml_attr(res_binding, "name")

  # eurovoc labels
  if (identical(unique(res_cols), c("eurovoc","labels"))){

    out <- data.frame(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="eurovoc", T, NA)) %>%
      dplyr::group_by(.data$is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(.data$is_work==T, .data$triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(.data$triplet) %>%
      dplyr::select(-"is_work") %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-"triplet")

  } 
  
  # regular result
  else {

    out <- data.frame(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="work", T, NA)) %>%
      dplyr::group_by(.data$is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(.data$is_work==T, .data$triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(.data$triplet) %>%
      dplyr::select(-"is_work") %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-"triplet")

  }
  
  # strip URI
  if (strip_uri == TRUE){
    
    out <- out |> 
      dplyr::mutate(
        dplyr::across(dplyr::everything(), 
                      ~gsub("^http://publications.europa.eu/resource/cellar/|^http://publications.europa.eu/resource/authority/resource-type/","",.))
      )
    
  }

  # end
  return(out)

}
