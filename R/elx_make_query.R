#' Create SPARQL quries
#'
#' Generates pre-defined or manual SPARQL queries to retrieve document ids from Cellar.
#' List of available resource types: http://publications.europa.eu/resource/authority/resource-type .
#' Note that not all resource types are compatible with the pre-defined query.
#'
#' @importFrom magrittr %>%
#'
#' @param resource_type Type of resource to be retrieved via SPARQL query
#' @param manual_type Define manually the type of resource to be retrieved
#' @param include_corrigenda If `TRUE`, results include corrigenda
#' @param include_celex If `TRUE`, results include CELEX identifier for each resource URI
#' @param include_date If `TRUE`, results include document date
#' @param include_date_force If `TRUE`, results include date of entry into force
#' @param include_date_endvalid If `TRUE`, results include date of end of validity
#' @param include_date_transpos If `TRUE`, results include date of transposition deadline for directives
#' @param include_lbs If `TRUE`, results include legal bases of legislation
#' @param include_force If `TRUE`, results include whether legislation is in force
#' @param include_eurovoc If `TRUE`, results include EuroVoc descriptors of subject matter
#' @param include_author If `TRUE`, results include document author(s)
#' @param include_citations If `TRUE`, results include citations (CELEX-labelled)
#' @param order Order results by ids
#' @param limit Limit the number of results, for testing purposes mainly
#' @return
#' A character string containing the SPARQL query
#' @export
#' @examples
#' elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE)
#' elx_make_query(resource_type = "regulation", include_corrigenda = TRUE, order = TRUE)
#' elx_make_query(resource_type = "caselaw")
#' elx_make_query(resource_type = "manual", manual_type = "SWD")

elx_make_query <- function(resource_type = c("directive","regulation","decision","recommendation","intagr","caselaw","manual","proposal","national_impl"),
                           manual_type = "", include_corrigenda = FALSE, include_celex = TRUE, include_lbs = FALSE,
                           include_date = FALSE, include_date_force = FALSE, include_date_endvalid = FALSE,
                           include_date_transpos = FALSE, include_force = FALSE, include_eurovoc = FALSE,
                           include_author = FALSE, include_citations = FALSE, order = FALSE, limit = NULL){

  if (!resource_type %in% c("directive","regulation","decision","recommendation","intagr","caselaw","manual","proposal","national_impl")) stop("'resource_type' must be defined")

  if (resource_type == "manual" & nchar(manual_type) < 2){
    stop("Please specify resource type manually (e.g. 'DIR', 'REG', 'JUDG').", call. = TRUE)
  }

  if (include_date_transpos == TRUE & resource_type!="directive"){
    stop("Transposition date currently only available for directives.", call. = TRUE)
  }

  query <- "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>
  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>
  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
  PREFIX dc:<http://purl.org/dc/elements/1.1/>
  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX owl:<http://www.w3.org/2002/07/owl#>
  select distinct ?work ?type"

  if (include_celex == TRUE){

    query <- paste(query, "?celex", sep = " ")

  }

  if (include_date == TRUE){

    query <- paste(query, "str(?date)", sep = " ")

  }

  if (include_date_force == TRUE){

    query <- paste(query, "str(?dateforce)", sep = " ")

  }

  if (include_date_endvalid == TRUE){

    query <- paste(query, "str(?dateendvalid)", sep = " ")

  }

  if (include_date_transpos == TRUE){

    query <- paste(query, "str(?datetranspos)", sep = " ")

  }

  if (include_lbs == TRUE){

    if (resource_type %in% c("caselaw")){
      stop("Legal basis variable incompatible with requested resource type", call. = TRUE)
    }

    query <- paste(query, "?lbs ?lbcelex ?lbsuffix", sep = " ")

  }

  if (include_force == TRUE){

    if (resource_type %in% c("caselaw")){
      stop("Force variable incompatible with requested resource type", call. = TRUE)
    }

    query <- paste(query, "?force", sep = " ")

  }

  if (include_eurovoc == TRUE){

    query <- paste(query, "?eurovoc", sep = " ")

  }

  if (include_author == TRUE){

    query <- paste(query, "?author", sep = " ")

  }

  if (include_citations == TRUE){

    query <- paste(query, "?citationcelex", sep = " ")

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
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/MEMORANDUM_UNDERST>)", sep = " ")
  }

  if (resource_type == "decision"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_ENTSCHEID>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DEL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_FRAMW>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_DEC>)", sep = " ")
  }

  if (resource_type == "caselaw"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_JUR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/THIRDPARTY_PROCEED>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/GARNISHEE_ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RULING>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG_EXTRACT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/INFO_JUDICIAL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/VIEW_AG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_AG>)", sep = " ")
  }

  if (resource_type == "proposal"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_REG_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DIR_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_RECO>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_ACTION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_RES>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_OPIN>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DECLAR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_FRAMW>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RES_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DECLAR_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_FRAMW_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_ACTION_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/COMMUNIC_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_EUMS_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERINSTIT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERNATION_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_UBEREINKOM_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_PRELIM>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_PRELIM_SUPPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_SUPPL_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_NO_ADDRESSEE>)", sep = " ")
  }

  if (resource_type == "national_impl"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/MEAS_NATION_IMPL>", sep = " ")
  }

  if (nchar(manual_type) > 1 & resource_type == "manual"){
    query <- paste(query, "FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/", manual_type, ">)", sep = "")
  }

  if (include_corrigenda == FALSE & resource_type!="caselaw"){
    query <- paste(query,"\n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>}", sep = " ")
  }

  if (include_celex == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:resource_legal_id_celex ?celex.}")

  }

  if (include_date == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:work_date_document ?date.}")

  }

  if (include_date_force == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:resource_legal_date_entry-into-force ?dateforce.}")

  }

  if (include_date_endvalid == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:resource_legal_date_end-of-validity ?dateendvalid.}")

  }

  if (include_date_transpos == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:directive_date_transposition ?datetranspos.}")

  }

  if (include_lbs == TRUE & resource_type!="caselaw"){

    query <- paste(query, "OPTIONAL{?work cdm:resource_legal_based_on_resource_legal ?lbs.
    ?lbs cdm:resource_legal_id_celex ?lbcelex.
    OPTIONAL{?bn owl:annotatedSource ?work.
    ?bn owl:annotatedProperty <http://publications.europa.eu/ontology/cdm#resource_legal_based_on_resource_legal>.
    ?bn owl:annotatedTarget ?lbs.
    ?bn annot:comment_on_legal_basis ?lbsuffix}}",
                   sep = " ")

  }

  if (include_force == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:resource_legal_in-force ?force.}")

  }

  if (include_eurovoc == TRUE){

    query <- paste(query, 'OPTIONAL{?work cdm:work_is_about_concept_eurovoc ?eurovoc. graph ?gs
    { ?eurovoc skos:prefLabel ?subjectLabel filter (lang(?subjectLabel)="en") }.}')

  }

  if (include_author == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:work_created_by_agent ?author.}")

  }

  if (include_citations == TRUE){

    query <- paste(query, "OPTIONAL{?work cdm:work_cites_work ?citation. ?citation cdm:resource_legal_id_celex ?citationcelex.}")

  }

  if (order == TRUE){
    query <- paste(query, "} order by str(?date)")
  } else {query <- paste(query, "}")}

  if (!is.null(limit) & is.integer(as.integer(limit))){
    query <- paste(query, "limit", limit, sep = " ")
  }

  return(query)

}

