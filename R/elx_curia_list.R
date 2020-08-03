#' Scrape list of court cases from Curia
#'
#' Harvests data from lists of EU court cases from curia.europa.eu.
#' CELEX identifiers are extracted from hyperlinks where available.
#'
#' @param data Data to be scraped from three separate lists of cases maintained by Curia, defaults to "all"
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' \donttest{
#' elx_curia_list(data = "gc_all")
#' }

elx_curia_list <- function(data = c("all","ecj_old","ecj_new","gc_all")){

  url_c1 <- "https://curia.europa.eu/en/content/juris/c1_juris.htm"
  url_c2 <- "https://curia.europa.eu/en/content/juris/c2.htm"
  url_t2 <- "https://curia.europa.eu/en/content/juris/t2_juris.htm"

  if (missing(data)){

    data <- "all"

  }

  else {data <- match.arg(data)}


  if (data == "all"){

    res_c1 <- elx_curia_scraper(url_c1)
    res_c2 <- elx_curia_scraper(url_c2)
    res_t2 <- elx_curia_scraper(url_t2)

    return(rbind(res_c1, res_c2, res_t2))

  }

  else if (data == "ecj_old"){

    res_c1 <- elx_curia_scraper(url_c1)

    return(res_c1)

  }

  else if (data == "ecj_new"){

    res_c2 <- elx_curia_scraper(url_c2)

    return(res_c2)

  }

  else if (data == "gc_all"){

    res_t2 <- elx_curia_scraper(url_t2)

    return(res_t2)

  }


}


#' Scraper function
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

elx_curia_scraper <- function(url){

  page <- xml2::read_html(url)

  tab <- page %>%
    rvest::html_node("table") %>%
    rvest::html_table(header = FALSE, fill = TRUE) %>%
    dplyr::na_if("") %>%
    dplyr::filter_at(dplyr::vars(.data$X1,.data$X2), dplyr::all_vars(!is.na(.data))) %>%
    dplyr::rename(case_id = .data$X1,
                  case_info = .data$X2)

  hrefs <- page %>%
    xml2::xml_find_all('//a[contains(@href, "numdoc")]')

  linked_id <- rvest::html_text(hrefs, "href")

  linked_celex <- rvest::html_attr(hrefs, "href") %>%
    stringr::str_extract("numdoc=.*") %>%
    stringr::str_remove("\\'.*") %>%
    stringr::str_remove("numdoc=")

  linked <- data.frame(linked_id, linked_celex, stringsAsFactors = FALSE)

  return(dplyr::left_join(tab, linked, by = c("case_id"="linked_id")))

}

