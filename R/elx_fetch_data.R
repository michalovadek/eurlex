#' Retrieve additional data on EU documents
#'
#' Wraps httr::GET with pre-specified headers to retrieve data.
#'
#' @param url A valid url, preferably to a Cellar work obtained through `elx_run_query`.
#' @param type The type of data to be retrieved
#' @param language_1 The priority language in which the data will be attempted to be retrieved, in ISO 639 2-char code
#' @param language_2 If data not available in `language_1`, try `language_2`
#' @param language_3 If data not available in `language_2`, try `language_3`
#' @export
#' @examples
#' \donttest{
#' elx_fetch_data(url = ".../resource/cellar/3f7ccca4-478c-4a95-8778-df4243e30d0e", type = "text")
#' elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32014R0001", type = "title")
#' }

elx_fetch_data <- function(url, type = c("title","text","ids"),
                           language_1 = "en", language_2 = "fr", language_3 = "de"){

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
                                     'Accept' = 'text/html, application/xhtml+xml'
                   )
    )

    if (httr::status_code(response)==200){

      out <- response %>%
        xml2::read_html() %>%
        rvest::html_text()

    } else {out <- httr::status_code(response)}

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


  return(out)

}




