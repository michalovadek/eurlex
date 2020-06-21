#' Retrieve additional data on EU documents
#'
#' @param type The type of data to be retrieved
#' @param language The language in which the data will be retrieved
#' @export
#' @examples
#' elx_fetch_data(url = cellar_uri, type = "text")
#' elx_fetch_data(url = cellar_uri, type = "title")

elx_fetch_data <- function(url, type = c("title","text","ids"), language = "eng"){

  if (type == "title"){

    response <- httr::GET(url=url,
                          httr::add_headers('Accept-Language' = language,
                                            'Accept' = 'application/xml; notice=object'
                          )
    )

    if (status_code(response)==200){

      out <- httr::content(response) %>%
          xml2::xml_children() %>%
          xml2::xml_find_first("EXPRESSION_TITLE") %>%
          xml2::xml_find_first("VALUE") %>%
          xml2::xml_text()

    } else {out <- status_code(response)}

  }

  if (type == "text"){

    response <- httr::GET(url=url,
                   httr::add_headers('Accept-Language' = language,
                                     'Accept' = 'text/html, application/xhtml+xml'
                   )
    )

    if (status_code(response)==200){

      out <- response %>%
        xml2::read_html() %>%
        rvest::html_text()

    } else {out <- status_code(response)}

  }

  if (type == "ids"){

    response <- httr::GET(url=url,
                          httr::add_headers('Accept-Language' = language,
                                            'Accept' = 'application/xml; notice=identifiers'
                          )
    )

    if (status_code(response)==200){

      out <- httr::content(response) %>%
        xml2::xml_children() %>%
        xml2::xml_find_all(".//VALUE") %>%
        xml2::xml_text()

    } else {out <- status_code(response)}

  }


  return(out)

}

