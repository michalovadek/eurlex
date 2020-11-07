#' Parse RDF/XML triplets to data frame
#'
#' An internal function to parse RDF/XML output from SPARQL queries.
#'
#' @param sparql_response A valid response from the SPARQL endpoint
#' @importFrom rlang .data
#'

elx_parse_xml <- function(sparql_response = ""){

  res_binding <- sparql_response %>%
    xml2::read_xml() %>%
    xml2::xml_find_all("//d1:binding")

  res_text <- res_binding %>%
    xml2::xml_text()

  res_cols <- res_binding %>%
    xml2::xml_attr("name")

  if (sum(unique(res_cols) == c("eurovoc","labels")) == 2){ # for use in elx_label_eurovoc

    out <- dplyr::tibble(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="eurovoc", T, NA)) %>%
      dplyr::group_by(is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(is_work==T, triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(triplet) %>%
      dplyr::select(-.data$is_work) %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-.data$triplet)

  } else {

    out <- dplyr::tibble(res_cols, res_text) %>%
      dplyr::mutate(is_work = dplyr::if_else(res_cols=="work", T, NA)) %>%
      dplyr::group_by(is_work) %>%
      dplyr::mutate(triplet = dplyr::row_number(),
                    triplet = dplyr::if_else(is_work==T, triplet, NA_integer_)) %>%
      dplyr::ungroup() %>%
      tidyr::fill(triplet) %>%
      dplyr::select(-.data$is_work) %>%
      tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
      dplyr::select(-.data$triplet)

  }

  return(out)

}

