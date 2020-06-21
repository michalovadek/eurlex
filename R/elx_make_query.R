#' Create SPARQL quries
#'
#' Generates pre-defined or manual SPARQL queries to retrieve document ids from Cellar.
#' Mainly to be called internally by other functions.
#' List of available resource types: http://publications.europa.eu/resource/authority/resource-type .
#' Note that not all resource types are compatible with the pre-defined query.
#'
#' @param resource_type Type of resource to be retrieved via SPARQL query
#' @param manual_type Define manually the type of resource to be retrieved
#' @param include_corrigenda If `TRUE`, results include corrigenda
#' @param include_celex If `TRUE`, results include CELEX identifier for each resource URI
#' @param include_date If `TRUE`, results include document date
#' @param include_lbs If `TRUE`, results include legal bases of legislation
#' @param include_force If `TRUE`, results include whether legislation is in force
#' @param order Order results by ids
#' @export
#' @examples
#' elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE)
#' elx_make_query(resource_type = "regulation", include_corrigenda = TRUE, order = TRUE)
#' elx_make_query(resource_type = "caselaw")
#' elx_make_query(resource_type = "manual", manual_type = "SWD")

elx_make_query <- function(resource_type = c("directive","regulation","decision","recommendation","intagr","caselaw","manual"),
                           manual_type = "", include_corrigenda = FALSE, include_celex = TRUE, include_lbs = FALSE,
                           include_date = FALSE, include_force = FALSE, order = FALSE){

  if (!resource_type %in% c("directive","regulation","decision","recommendation","intagr","caselaw","manual")) stop("'resource_type' must be defined")

  if (resource_type == "manual" & nchar(manual_type) < 2){
    stop("Please specify resource type manually (e.g. 'DIR', 'REG', 'JUDG').", call. = TRUE)
  }

  query <- "prefix cdm: <http://publications.europa.eu/ontology/cdm#>
  select distinct ?work ?type"

  # cdm:resource_legal_date_end-of-validity	in_notice
  # cdm:resource_legal_date_entry-into-force

  if (include_celex == TRUE){

    query <- paste(query, "?celex", sep = " ")

  }

  if (include_date == TRUE){

    query <- paste(query, "str(?date)", sep = " ")

  }

  if (include_lbs == TRUE & resource_type!="caselaw"){

    query <- paste(query, "?lbs ?lbcelex", sep = " ")

  }

  if (include_force == TRUE & resource_type!="caselaw"){

    query <- paste(query, "?force", sep = " ")

  }

  query <- paste(query, "where{ ?work cdm:work_has_resource-type ?type.", sep = " ")

  if (resource_type == "directive"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL>)", sep = " ")
  }

  if (resource_type == "recommendation"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/RECO>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DEC>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DIR>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_OPIN>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_RES>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_REG>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_RECO>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DRAFT>)", sep = " ")
  }

  if (resource_type == "regulation"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_FINANC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL>)", sep = " ")
  }

  if (resource_type == "intagr"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/EXCH_LET>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_PROT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_ADOPT_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ARRANG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/CONVENTION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/MEMORANDUM_UNDERST>)", sep = " ")
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

  if (resource_type == "caselaw"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_JUR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/THIRDPARTY_PROCEED>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/GARNISHEE_ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RULING>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG_EXTRACT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/VIEW_AG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_AG>)", sep = " ")
  }

  if (nchar(manual_type) > 1 & resource_type == "manual"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/", manual_type, ">)", sep = "")
  }

  if (include_corrigenda == FALSE & resource_type!="caselaw"){
    query <- paste(query,"\n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>}", sep = " ")
  }

  #query <- paste(query, "?work cdm:work_id_document ?doc_id.")

  if (include_celex == TRUE){

    query <- paste(query, "?work cdm:resource_legal_id_celex ?celex.")

  }

  if (include_date == TRUE){

    query <- paste(query, "?work cdm:work_date_document ?date.")

  }

  if (include_lbs == TRUE & resource_type!="caselaw"){

    query <- paste(query, "?work cdm:resource_legal_based_on_resource_legal ?lbs.
                   ?lbs cdm:resource_legal_id_celex ?lbcelex.",
                   sep = " ")

  }

  if (include_force == TRUE){

    query <- paste(query, "?work cdm:resource_legal_in-force ?force.")

  }

  if (order == TRUE){
    query <- paste(query, "} order by str(?date)")
  } else {query <- paste(query, "}")}

  return(query)

}
