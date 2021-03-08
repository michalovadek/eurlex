#' Scrape list of court cases from Curia
#'
#' Harvests data from lists of EU court cases from curia.europa.eu.
#' CELEX identifiers are extracted from hyperlinks where available.
#'
#' @param data Data to be scraped from four separate lists of cases maintained by Curia, defaults to "all"
#' which contains cases from Court of Justice, General Court and Civil Service Tribunal.
#' @param parse If `TRUE`, references to cases and appeals are parsed out from `case_info` into separate columns
#' @return
#' A data frame containing case identifiers and information as character columns. Where the case id
#' contains a hyperlink to Eur-Lex, the CELEX identifier is retrieved as well.
#' @importFrom rlang .data
#' @export
#' @examples
#' \donttest{
#' elx_curia_list(data = "cst_all")
#' }

elx_curia_list <- function(data = c("all","ecj_old","ecj_new","gc_all","cst_all"),
                           parse = TRUE){

  url_c1 <- "https://curia.europa.eu/en/content/juris/c1_juris.htm"
  url_c2 <- "https://curia.europa.eu/en/content/juris/c2_juris.htm"
  url_t2 <- "https://curia.europa.eu/en/content/juris/t2_juris.htm"
  url_f1 <- "https://curia.europa.eu/en/content/juris/f1_juris.htm"

  if (missing(data)){

    data <- "all"

  }

  else {data <- match.arg(data)}


  if (data == "all"){

    res_c1 <- elx_curia_scraper(url_c1)
    res_c2 <- elx_curia_scraper(url_c2)
    res_t2 <- elx_curia_scraper(url_t2)
    res_f1 <- elx_curia_scraper(url_f1)

    res_all <- rbind(res_c1, res_c2, res_t2, res_f1)

    if (parse == TRUE){res_all <- elx_curia_parse(res_all)}

    return(res_all)

  }

  else if (data == "ecj_old"){

    res_c1 <- elx_curia_scraper(url_c1)

    if (parse == TRUE){res_c1 <- elx_curia_parse(res_c1)}

    return(res_c1)

  }

  else if (data == "ecj_new"){

    res_c2 <- elx_curia_scraper(url_c2)

    if (parse == TRUE){res_c2 <- elx_curia_parse(res_c2)}

    return(res_c2)

  }

  else if (data == "gc_all"){

    res_t2 <- elx_curia_scraper(url_t2)

    if (parse == TRUE){res_t2 <- elx_curia_parse(res_t2)}

    return(res_t2)

  }

  else if (data == "cst_all"){

    res_f1 <- elx_curia_scraper(url_f1)

    if (parse == TRUE){res_f1 <- elx_curia_parse(res_f1)}

    return(res_f1)

  }


}

#' Curia scraper function
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

elx_curia_scraper <- function(url, ...){

  page <- xml2::read_html(url)

  tab <- page %>%
    rvest::html_node("table") %>%
    rvest::html_table(header = FALSE, fill = TRUE) %>%
    dplyr::na_if("") %>%
    dplyr::filter(!is.na(.data$X1) & !is.na(.data$X2)) %>%
    dplyr::rename(case_id = .data$X1,
                  case_info = .data$X2) %>%
    dplyr::group_by(.data$case_id) %>%
    dplyr::mutate(n_id = dplyr::row_number()) %>%
    dplyr::ungroup()

  hrefs <- page %>%
    xml2::xml_find_all('//a[contains(@href, "numdoc")]')

  linked_id <- rvest::html_text(hrefs, "href")

  linked_celex <- rvest::html_attr(hrefs, "href") %>%
    stringr::str_extract("numdoc=.*") %>%
    stringr::str_remove("\\'.*") %>%
    stringr::str_remove("numdoc=")

  linked <- data.frame(linked_id, linked_celex, stringsAsFactors = FALSE) %>%
    dplyr::group_by(.data$linked_id) %>%
    dplyr::mutate(n_id = dplyr::row_number()) %>%
    dplyr::ungroup()

  out <- dplyr::left_join(tab, linked, by = c("case_id"="linked_id","n_id"="n_id")) %>%
    dplyr::select(.data$case_id, .data$linked_celex, .data$case_info) %>%
    dplyr::rename(case_id_celex = linked_celex)

  return(out)

}

#' Curia parser function
#'
#' @importFrom rlang .data
#'
#' @noRd
#'

elx_curia_parse <- function(x, ...){

  out <- x %>%
    dplyr::mutate(ecli = stringr::str_extract(.data$case_info, "ECLI:EU:[:upper:]:[:digit:]{4}:[:digit:]+"),
                  see_case = stringr::str_extract(.data$case_info, "see Case .+") %>%
                    stringr::str_remove("see Case ") %>%
                    stringr::str_remove("APPEAL.*") %>%
                    stringr::str_squish() %>%
                    stringr::str_trim(),
                  appeal = stringr::str_extract(.data$case_info, "APPEAL.*") %>%
                    stringr::str_remove("APPEAL.? :") %>%
                    stringr::str_remove_all("\\;|\\,|\\.") %>%
                    stringr::str_squish() %>%
                    stringr::str_trim()
    )

  return(out)

}

