#' Consolidate SPARQL results for preset queries
#'
#'@importFrom magrittr %>%
#'

elx_consolidate <- function(sparql_response){

  sparql_response$results %>%
    dplyr::group_by(work) %>%
    summarise(ids = paste(callret.1, collapse = ";"),
              type) %>%
    ungroup() %>%
    mutate(n_ids = stringr::str_count(ids, ";")+1,
           year = as.integer(stringr::str_extract(ids,"19[:digit:][:digit:]|20[:digit:][:digit:]")))

}

elx_consolidate(directives) %>%
  ggplot(aes(x = year)) + geom_bar()

