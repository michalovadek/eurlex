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
    xml2::xml_ns_strip() %>%
    xml2::xml_find_all("//binding")

  res_text <- res_binding %>%
    xml2::xml_text()

  res_cols <- res_binding %>%
    xml2::xml_attr("name")

  unique(res_cols)

  out <- dplyr::tibble(res_cols, res_text) %>%
    dplyr::mutate(is_work = ifelse(res_cols=="work", T, NA)) %>%
    dplyr::group_by(is_work) %>%
    dplyr::mutate(triplet = dplyr::row_number(),
                  triplet = ifelse(is_work==T, triplet, NA)) %>%
    dplyr::ungroup() %>%
    tidyr::fill(triplet) %>%
    dplyr::select(-.data$is_work) %>%
    tidyr::pivot_wider(names_from = res_cols, values_from = res_text) %>%
    dplyr::select(-.data$triplet)

  return(out)

}

# res_list <- res %>%
#   xml2::read_xml() %>%
#   xml2::xml_ns_strip() %>%
#   xml2::xml_find_all("//result") %>%
#   xml2::as_list()
#
# res_df <- res_list %>%
#   do.call(rbind,.) %>%
#   as.data.frame()



