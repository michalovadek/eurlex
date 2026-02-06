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
    sparql_response_parsed <- elx_parse_xml(sparql_response)

  } else {return(invisible(NULL))}

  # return
  return(sparql_response_parsed)

}

#' Fail http call gracefully
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
  
  # if missing verb pick GET
  if (missing(verb)){
    verb <- "GET"
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
      message(conditionMessage(e), " (Error)")
      return(invisible(NULL))
    },
    warning = function(w) {
      message(conditionMessage(w), " (Warning)")
      return(invisible(NULL))
    })
  }
  
  # Execute the request
  resp <- make_request(verb)
  
  # return
  return(resp)
  
}

#' Parse RDF/XML triplets to data frame
#' An internal function to parse RDF/XML output from SPARQL queries.
#'
#' @noRd
#'

elx_parse_xml <- function(sparql_response = "", strip_uri = TRUE){

  # process XML response
  xml_doc <- xml2::read_xml(sparql_response)
  res_binding <- xml2::xml_find_all(xml_doc, "//d1:binding")

  res_text <- xml2::xml_text(res_binding) 

  res_cols <- xml2::xml_attr(res_binding, "name")

  # eurovoc labels
  if (identical(unique(res_cols), c("eurovoc","labels"))){

    df <- data.frame(res_cols = res_cols, res_text = res_text, stringsAsFactors = FALSE)
    df$triplet <- cumsum(df$res_cols == "eurovoc")
    out <- stats::reshape(df, idvar = "triplet", timevar = "res_cols", direction = "wide")
    names(out) <- sub("^res_text\\.", "", names(out))
    out$triplet <- NULL

  }

  # regular result
  else {

    df <- data.frame(res_cols = res_cols, res_text = res_text, stringsAsFactors = FALSE)
    df$triplet <- cumsum(df$res_cols == "work")
    out <- stats::reshape(df, idvar = "triplet", timevar = "res_cols", direction = "wide")
    names(out) <- sub("^res_text\\.", "", names(out))
    out$triplet <- NULL

  }
  
  # strip URI
  if (strip_uri == TRUE){

    uri_pattern <- "^http://publications.europa.eu/resource/cellar/|^http://publications.europa.eu/resource/authority/resource-type/"
    out[] <- lapply(out, function(x) gsub(uri_pattern, "", x))

  }

  # end
  return(out)

}
