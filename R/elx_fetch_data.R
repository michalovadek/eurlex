#' Retrieve additional data on EU documents
#'
#' Get titles, texts, identifiers and XML notices for EU resources.
#'
#' @param url A valid url as character vector of length one based on a resource identifier such as CELEX or Cellar URI.
#' @param type The type of data to be retrieved. When type = "text", the returned list contains named elements reflecting the source of each text. When type = "notice", the results return an XML notice associated with the url.
#' @param notice If type = "notice", controls what kind of metadata are returned by the notice.
#' @param language_1 The priority language in which the data will be attempted to be retrieved, in ISO 639 2-char code
#' @param language_2 If data not available in `language_1`, try `language_2`
#' @param language_3 If data not available in `language_2`, try `language_3`
#' @param include_breaks If TRUE, text includes tags showing where pages ("---pagebreak---", for pdfs) and documents ("---documentbreak---") were concatenated
#' @param html_text Choose whether to read text from html using [rvest::html_text2()] ("text2") or [rvest::html_text()] ("text")
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

  # format language query
  language <- paste(language_1,", ",language_2,";q=0.8, ",language_3,";q=0.7", sep = "")

  # process URL
  if (grepl("celex.*[\\(|\\)|\\/]", url)){

    clx <- sub(".*celex/", "", url)
    clx <- gsub("\\(", "%28", clx)
    clx <- gsub("\\)", "%29", clx)
    clx <- gsub("/", "%2F", clx)

    url <- paste("http://publications.europa.eu/resource/celex/",
                 clx,
                 sep = "")

  }

  # titles
  if (type == "title"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Accept' = 'application/xml; notice=object'),
                              verb = "GET")
    
    # if var not created, break
    if (is.null(response)){
      
      return(invisible(NULL))
      
    }

    if (httr::status_code(response)==200){

      content <- httr::content(response)
      expr_title <- xml2::xml_find_first(content, "//EXPRESSION_TITLE")
      value_node <- xml2::xml_find_first(expr_title, "VALUE")
      out <- xml2::xml_text(value_node)

    } else {out <- httr::status_code(response)}

  }

  # full text
  if (type == "text"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Content-Language' = language,
                                                          'Accept' = 'text/html, text/html;type=simplified, text/plain, application/xhtml+xml, application/xhtml+xml;type=simplified, application/pdf, application/pdf;type=pdf1x, application/pdf;type=pdfa1a, application/pdf;type=pdfx, application/pdf;type=pdfa1b, application/msword'),
                              verb = "GET")

    # if var not created, break
    if (is.null(response)){
      
      return(invisible(NULL))
      
    }
    
    if (httr::status_code(response)==200){

      out <- elx_read_text(response, html_text = html_text)

    }

    else if (httr::status_code(response)==300){

      content <- httr::content(response, as = "text")
      html_doc <- xml2::read_html(content)
      body_node <- rvest::html_node(html_doc, "body")
      a_nodes <- rvest::html_nodes(body_node, "a")
      attrs <- rvest::html_attrs(a_nodes)
      links <- unlist(attrs)

      names(links) <- NULL

      multiout <- ""

      for (q in seq_along(links)){
        
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

      out <- gsub("---pagebreak---|---documentbreak---", "", out)

    }

  }

  # identifiers
  if (type == "ids"){
    
    response <- graceful_http(url,
                              headers = httr::add_headers('Accept-Language' = language,
                                                          'Accept' = 'application/xml; notice=identifiers'),
                              verb = "GET")
    
    # if var not created, break
    if (is.null(response)){
      
      return(invisible(NULL))
      
    }

    if (httr::status_code(response)==200){

      content <- httr::content(response)
      children <- xml2::xml_children(content)
      values <- xml2::xml_find_all(children, ".//VALUE")
      out <- xml2::xml_text(values)

    } else {out <- httr::status_code(response)}

  }
  
  # notices
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
    
    # if var not created, break
    if (is.null(response)){
      
      return(invisible(NULL))
      
    }
    
    if (httr::status_code(response)==200){
      
      out <- httr::content(response)
      
    } else {out <- httr::status_code(response)}
    
  }

  # end
  return(out)

}


#' Read text from http response
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
  
  if (grepl("html", http_response$headers$`content-type`)){

    html_doc <- xml2::read_html(http_response)
    body_node <- rvest::html_node(html_doc, "body")
    text_content <- html_text_engine(body_node)
    out <- paste0(text_content, collapse = " ---pagebreak--- ")

    names(out) <- "html"

  }

  else if (grepl("pdf", http_response$headers$`content-type`)){

    pdf_text <- pdftools::pdf_text(http_response$url)
    out <- paste0(pdf_text, collapse = " ---pagebreak--- ")

    names(out) <- "pdf"

  }

  else if (grepl("msword", http_response$headers$`content-type`)){

    word_text <- antiword::antiword(http_response$url)
    out <- paste0(word_text, collapse = " ---pagebreak--- ")

    names(out) <- "word"

  } else {
    out <- "unsupported format"
    names(out) <- "unsupported"
  }

  return(out)

}
