#' Retrieve additional data on EU documents
#'
#' Wraps httr::GET with pre-specified headers to retrieve data.
#'
#' @param url A valid url as character vector of length one based on a resource identifier such as CELEX or Cellar URI.
#' @param type The type of data to be retrieved. When type = "text", the returned list contains named elements reflecting the source of each text.
#' @param language_1 The priority language in which the data will be attempted to be retrieved, in ISO 639 2-char code
#' @param language_2 If data not available in `language_1`, try `language_2`
#' @param language_3 If data not available in `language_2`, try `language_3`
#' @param include_breaks If TRUE, text includes tags showing where pages ("---pagebreak---", for pdfs) and documents ("---documentbreak---") were concatenated
#' @return
#' A character vector of length one containing the result.
#' @export
#' @examples
#' \donttest{
#' elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32014R0001", type = "title")
#' }

elx_fetch_data <- function(url, type = c("title","text","ids"),
                           language_1 = "en", language_2 = "fr", language_3 = "de",
                           include_breaks = TRUE){

  language <- paste(language_1,", ",language_2,";q=0.8, ",language_3,";q=0.7", sep = "")

  if (type == "title"){

    response <- httr::GET(url=url,
                          httr::add_headers('Accept-Language' = language,
                                            'Accept' = 'application/xml; notice=object'
                          )
    )

    if (httr::status_code(response)==200){

      out <- httr::content(response) %>%
          xml2::xml_children() %>%
          xml2::xml_find_first("EXPRESSION_TITLE") %>%
          xml2::xml_find_first("VALUE") %>%
          xml2::xml_text()

    } else {out <- httr::status_code(response)}

  }

  if (type == "text"){

    response <- httr::GET(url=url,
                   httr::add_headers('Accept-Language' = language,
                                     'Content-Language' = language,
                                     'Accept' = 'text/html, text/html;type=simplified, text/plain, application/xhtml+xml, application/xhtml+xml;type=simplified, application/pdf, application/pdf;type=pdf1x, application/pdf;type=pdfa1a, application/pdf;type=pdfx, application/pdf;type=pdfa1b, application/msword'
                   )
    )

    if (httr::status_code(response)==200){

      out <- elx_read_text(response)

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

        multiresponse <- httr::GET(url=links[q],
                              httr::add_headers('Accept-Language' = language,
                                                'Content-Language' = language,
                                                'Accept' = 'text/html, text/html;type=simplified, text/plain, application/xhtml+xml, application/xhtml+xml;type=simplified, application/pdf, application/pdf;type=pdf1x, application/pdf;type=pdfa1a, application/pdf;type=pdfx, application/pdf;type=pdfa1b, application/msword'
                              )
        )

        if (httr::status_code(multiresponse)==200){

          multiout[q] <- elx_read_text(multiresponse)

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

  }

  if (type == "ids"){

    response <- httr::GET(url=url,
                          httr::add_headers('Accept-Language' = language,
                                            'Accept' = 'application/xml; notice=identifiers'
                          )
    )

    if (httr::status_code(response)==200){

      out <- httr::content(response) %>%
        xml2::xml_children() %>%
        xml2::xml_find_all(".//VALUE") %>%
        xml2::xml_text()

    } else {out <- httr::status_code(response)}

  }

  if (type == "exper"){

    response <- httr::GET(url=url,
                          httr::add_headers('Accept-Language' = language,
                                            'Accept' = 'application/rdf+xml'
                          )
    )

    if (httr::status_code(response)==200){

      out <- httr::content(response, as = "text")

    } else {out <- httr::status_code(response)}

  }

  if (include_breaks == FALSE){

    out <- out %>%
      stringr::str_remove_all(out,"---pagebreak---|---documentbreak---")

  }

  return(out)

}


#' Read text from http response
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

elx_read_text <- function(http_response){

    if (stringr::str_detect(http_response$headers$`content-type`,"html")){

      out <- http_response %>%
        xml2::read_html() %>%
        rvest::html_node("body") %>%
        rvest::html_text() %>%
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

