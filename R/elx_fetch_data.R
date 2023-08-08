#' Retrieve additional data on EU documents
#'
#' Wraps httr::GET with pre-specified headers and parses retrieved data.
#'
#' @param url A valid url as character vector of length one based on a resource identifier such as CELEX or Cellar URI.
#' @param type The type of data to be retrieved. When type = "text", the returned list contains named elements reflecting the source of each text. When type = "notice", the results return an XML notice associated with the url.
#' @param notice If type = "notice", controls what kind of metadata are returned by the notice.
#' @param language_1 The priority language in which the data will be attempted to be retrieved, in ISO 639 2-char code
#' @param language_2 If data not available in `language_1`, try `language_2`
#' @param language_3 If data not available in `language_2`, try `language_3`
#' @param include_breaks If TRUE, text includes tags showing where pages ("---pagebreak---", for pdfs) and documents ("---documentbreak---") were concatenated
#' @param html_text Choose whether to read text from html using `rvest::html_text2` ("text2") or `rvest::html_text` ("text")
#' @return
#' A character vector of length one containing the result. When `type = "text"`, named character vector where the name contains the source of the text.
#' @export
#' @examples
#' \donttest{
#' elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32014R0001", type = "title")
#' }

elx_fetch_data <- function(url, type = c("title","text","ids","notice"),
                           notice = c("tree","branch", "object"),
                           language_1 = "en", language_2 = "fr", language_3 = "de",
                           include_breaks = TRUE,
                           html_text = c("text2","text")){
  
  # html_text option
  if (missing(html_text)){
    
    html_text <- "text2"
    
  }
  
  # stopping criteria
  stopifnot("url must be specified" = !missing(url),
            "type must be specified" = !missing(type),
            "type must be correctly specified" = type %in% c("title","text","ids","notice"))
  
  if (type == "notice" & missing(notice)){stop("notice type must be given")}

  language <- paste(language_1,", ",language_2,";q=0.8, ",language_3,";q=0.7", sep = "")

  if (stringr::str_detect(url,"celex.*[\\(|\\)|\\/]")){

    clx <- stringr::str_extract(url, "(?<=celex\\/).*") %>% 
      stringr::str_replace_all("\\(","%28") %>% 
      stringr::str_replace_all("\\)","%29") %>% 
      stringr::str_replace_all("\\/","%2F")

    url <- paste("http://publications.europa.eu/resource/celex/",
                 clx,
                 sep = "")

  }

  if (type == "title"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Accept' = 'application/xml; notice=object'),
                              verb = "GET")

    if (httr::status_code(response)==200){

      out <- httr::content(response) %>% 
          xml2::xml_find_first("//EXPRESSION_TITLE") %>% 
          xml2::xml_find_first("VALUE") %>% 
          xml2::xml_text()

    } else {out <- httr::status_code(response)}

  }

  if (type == "text"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Content-Language' = language,
                                                          'Accept' = 'text/html, text/html;type=simplified, text/plain, application/xhtml+xml, application/xhtml+xml;type=simplified, application/pdf, application/pdf;type=pdf1x, application/pdf;type=pdfa1a, application/pdf;type=pdfx, application/pdf;type=pdfa1b, application/msword'),
                              verb = "GET")

    if (httr::status_code(response)==200){

      out <- elx_read_text(response, html_text = html_text)

    }

    else if (httr::status_code(response)==300){

      links <- response %>%
        httr::content(as = "text") %>%
        xml2::read_html() %>%
        rvest::html_node("body") %>%
        rvest::html_nodes("a") %>%
        rvest::html_attrs() %>% 
        unlist()

      names(links) <- NULL

      multiout <- ""

      for (q in 1:length(links)){
        
        multiresponse <- graceful_http(links[q],
                                       headers = httr::add_headers('Accept-Language' = language,
                                                              'Content-Language' = language,
                                                              'Accept' = 'text/html, text/html;type=simplified, text/plain, application/xhtml+xml, application/xhtml+xml;type=simplified, application/pdf, application/pdf;type=pdf1x, application/pdf;type=pdfa1a, application/pdf;type=pdfx, application/pdf;type=pdfa1b, application/msword'),
                                       verb = "GET")

        if (httr::status_code(multiresponse)==200){

          multiout[q] <- elx_read_text(multiresponse, html_text = html_text)

          multiout <- paste0(multiout, collapse = " ---documentbreak--- ")

        } else {
          multiout <- NA_character_
          names(multiout) <- "missingdoc"
          }

      }

      names(multiout) <- "multidocs"

      out <- multiout

    }

    else if (httr::status_code(response)==406){

      out <- NA

      names(out) <- "missingdoc"

    }
    
    if (include_breaks == FALSE){
      
      out <- stringr::str_remove_all(out,"---pagebreak---|---documentbreak---")
      
    }

  }

  if (type == "ids"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Accept' = 'application/xml; notice=identifiers'),
                              verb = "GET")

    if (httr::status_code(response)==200){

      out <- httr::content(response) %>%
        xml2::xml_children() %>%
        xml2::xml_find_all(".//VALUE") %>%
        xml2::xml_text()

    } else {out <- httr::status_code(response)}

  }
  
  if (type == "notice"){
    
    accept_header <- paste('application/xml; notice=',
                           notice,
                           sep = "")
    
    # if object notice, no language header
    if (notice == "object"){
      
      response <- graceful_http(url,
                            headers = httr::add_headers('Accept' = accept_header),
                            verb = "GET")
      
    }
    
    else {
      
      response <- graceful_http(url,
                            headers = httr::add_headers('Accept-Language' = language,
                                                        'Accept' = accept_header),
                            verb = "GET") 
      
    }
    
    if (httr::status_code(response)==200){
      
      out <- httr::content(response)
      
    } else {out <- httr::status_code(response)}
    
  }

  return(out)

}


#' Read text from http response
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

elx_read_text <- function(http_response, html_text = "text2"){

  # html_text option
  if (missing(html_text)){
    
    html_text_engine <- rvest::html_text2
    
  }
  
  else if (html_text == "text2"){
    
    html_text_engine <- rvest::html_text2
    
  }
  
  else if (html_text == "text"){
    
    html_text_engine <- rvest::html_text
    
  }
  
    if (stringr::str_detect(http_response$headers$`content-type`,"html")){

      out <- http_response %>%
        xml2::read_html() %>%
        rvest::html_node("body") %>%
        html_text_engine() %>%
        paste0(collapse = " ---pagebreak--- ")

      names(out) <- "html"

    }

    else if (stringr::str_detect(http_response$headers$`content-type`,"pdf")){

      out <- http_response$url %>%
        pdftools::pdf_text() %>%
        paste0(collapse = " ---pagebreak--- ")

      names(out) <- "pdf"

    }

    else if (stringr::str_detect(http_response$headers$`content-type`,"msword")){

      out <- http_response$url %>%
        antiword::antiword() %>%
        paste0(collapse = " ---pagebreak--- ")

      names(out) <- "word"

    } else {
      out <- "unsupported format"
      names(out) <- "unsupported"
    }

  return(out)

}
