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
#' contains a hyperlink to Eur-Lex, the CELEX identifier is retrieved as well. Hyperlinks to Eur-Lex
#' disappeared from more recent cases.
#' @export
#' @examples
#' \donttest{
#' elx_curia_list(data = "cst_all", parse = FALSE)
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
#' @noRd
#'

elx_curia_scraper <- function(url, ...){

  response <- graceful_http(url, verb = "GET")

  # if var not created, break
  if (is.null(response)){

    return(invisible(NULL))

  }

  page <- xml2::read_html(response)

  table_node <- rvest::html_node(page, "table")
  tab <- rvest::html_table(table_node, header = FALSE, fill = TRUE)
  tab[] <- lapply(tab, function(x) { x[x == ""] <- NA; x })
  tab <- tab[!is.na(tab$X1) & !is.na(tab$X2), , drop = FALSE]
  names(tab)[names(tab) == "X1"] <- "case_id"
  names(tab)[names(tab) == "X2"] <- "case_info"
  tab$n_id <- stats::ave(seq_len(nrow(tab)), tab$case_id, FUN = seq_along)

  hrefs <- xml2::xml_find_all(page, '//a[contains(@href, "numdoc")]')

  linked_id <- rvest::html_text(hrefs, trim = TRUE)

  href_attr <- rvest::html_attr(hrefs, "href")
  linked_celex <- sub(".*numdoc=", "", href_attr)
  linked_celex <- sub("\\'.*", "", linked_celex)

  linked <- data.frame(linked_id = linked_id, linked_celex = linked_celex, stringsAsFactors = FALSE)
  linked$n_id <- stats::ave(seq_len(nrow(linked)), linked$linked_id, FUN = seq_along)

  out <- merge(tab, linked, by.x = c("case_id", "n_id"), by.y = c("linked_id", "n_id"), all.x = TRUE)
  out <- out[, c("case_id", "linked_celex", "case_info")]
  names(out)[names(out) == "linked_celex"] <- "case_id_celex"

  return(out)

}

#' Curia parser function
#'
#' @noRd
#'

elx_curia_parse <- function(x, ...){

  # Helper for str_extract (returns NA for no match)
  extract_first <- function(text, pattern) {
    m <- regexpr(pattern, text, perl = TRUE)
    result <- rep(NA_character_, length(text))
    matched <- m != -1
    result[matched] <- regmatches(text[matched], m[matched])
    result
  }

  # Helper for str_squish
  squish <- function(text) {
    trimws(gsub("\\s+", " ", text))
  }

  out <- x
  out$ecli <- extract_first(out$case_info, "ECLI:EU:[A-Z]:[0-9]{4}:[0-9]+")

  see_case <- extract_first(out$case_info, "see Case .+")
  see_case <- sub("see Case ", "", see_case)
  see_case <- sub("APPEAL.*", "", see_case)
  out$see_case <- squish(see_case)

  appeal <- extract_first(out$case_info, "APPEAL.*")
  appeal <- sub("APPEAL.? :", "", appeal)
  appeal <- gsub("[;,.]", "", appeal)
  out$appeal <- squish(appeal)

  return(out)

}
