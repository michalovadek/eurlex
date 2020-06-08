#' Create SPARQL quries
#'
#' Generates pre-defined or manual SPARQL queries.
#' Mainly to be called internally by other functions.
#'
#' @param resource_type Type of resource to be retrieved via SPARQL query, presets include "directive", "regulation" and "decision"
#' @param manual_type Define manually the type of resource to be retrieved, see \url(http://publications.europa.eu/resource/authority/resource-type)
#' @param include_corrigenda Should the query include corrigenda? Defaults to FALSE
#' @param order Order results by ids, defaults to TRUE
#' @keywords SPARQL
#' @export
#' @examples
#' elx_make_query(resource_type = "directive")
#' elx_make_query(resource_type = "regulation")
#' elx_make_query(resource_type = "decision")
#' elx_make_query(resource_type = "manual", manual_type = "SWD")

elx_make_query <- function(resource_type, manual_type, include_corrigenda = FALSE, order = TRUE){

  if (!resource_type %in% c("directive","regulation","decision","manual")) stop("'resource_type' must be defined")

  if (resource_type == "manual" & nchar(manual_type) < 2){
    stop("manual SPARQL query undefined", call. = TRUE)
  }

  query <- "
  prefix cdm: <http://publications.europa.eu/ontology/cdm#>
  select distinct ?work str(?doc_id) ?type
  where{
  ?work cdm:work_has_resource-type ?type.
  "

  if (resource_type == "directive"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL>)", sep = " ")
  }

  if (resource_type == "regulation"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL>)", sep = " ")
  }

  if (resource_type == "decision"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_ENTSCHEID>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DEL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_FRAMW>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_NC>)", sep = " ")
  }

  if (nchar(manual_type) > 1 & resource_type == "manual"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/", manual_type, ">)", sep = "")
  }

  if (include_corrigenda == FALSE){
    query <- paste(query,"FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>}", sep = " ")
  }

  query <- paste(query, "?work cdm:work_id_document ?doc_id.}")

  if (order == TRUE){
    query <- paste(query, "order by str(?doc_id)")
  }

  return(query)

}
