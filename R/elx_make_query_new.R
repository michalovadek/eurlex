#' PROTOTYYPPI - uusi datavetoinen query builder
#' Testattu neljällä kentällä: celex, date, force, author
#' Tarkoitus: validoida arkkitehtuuri ennen kaikkien ~25 kentän lisäämistä

# ---- 1. Kenttien määrittely yhdessä paikassa ----

field_specs <- list(
  
  celex = list(
    select_vars = "?celex",
    where = "OPTIONAL{?work cdm:resource_legal_id_celex ?celex.}",
    aggregatable = TRUE,
    incompatible_with = NULL
  ),
  
  date = list(
    select_vars = "?date",
    where = "OPTIONAL{?work cdm:work_date_document ?date.}",
    aggregatable = FALSE,  # yksi dokumentti = yksi päivämäärä tyypillisesti
    incompatible_with = NULL
  ),
  
  force = list(
    select_vars = "?force",
    where = "OPTIONAL{?work cdm:resource_legal_in-force ?force.}",
    aggregatable = FALSE,
    incompatible_with = "caselaw"
  ),
  
  author = list(
    select_vars = "?author",
    where = "OPTIONAL{?work cdm:work_created_by_agent ?authorx.
                   ?authorx skos:prefLabel ?author. FILTER(lang(?author)='en')}.",
    aggregatable = TRUE,
    incompatible_with = NULL
  ),
  
  ecli = list(
    select_vars = "?ecli",
    where = "OPTIONAL{?work cdm:case-law_ecli ?ecli.}",
    aggregatable = FALSE,
    incompatible_with = NULL
  ),
  
  court_procedure = list(
    select_vars = "?courtprocedure",
    where = "OPTIONAL{?work cdm:case-law_has_type_procedure_concept_type_procedure ?proc.
           ?proc skos:prefLabel ?courtprocedure. FILTER(lang(?courtprocedure)='en')}.",
    aggregatable = TRUE,
    incompatible_with = NULL
  ),
  
  eurovoc = list(
    select_vars = "?eurovoc",
    where = 'OPTIONAL{?work cdm:work_is_about_concept_eurovoc ?eurovoc. graph ?gs
    { ?eurovoc skos:prefLabel ?subjectLabel filter (lang(?subjectLabel)="en") }.}',
    aggregatable = TRUE,
    incompatible_with = NULL
  ),
  
  directory_code = list(
    select_vars = "?directory",
    where = "OPTIONAL{?work cdm:resource_legal_is_about_concept_directory-code ?directory.}",
    aggregatable = TRUE,
    incompatible_with = NULL
  ),
  
  sector = list(
    select_vars = "?sector",
    where = "OPTIONAL{?work cdm:resource_legal_id_sector ?sector.}",
    aggregatable = FALSE,
    incompatible_with = NULL
  )
  
)

# ---- 2. Pääfunktio ----

elx_make_query_new <- function(resource_type,
                               manual_type = "",
                               include_celex = TRUE,
                               include_date = FALSE,
                               date_from = NULL,
                               date_to = NULL,
                               include_force = FALSE,
                               include_author = FALSE,
                               include_ecli = FALSE,
                               include_court_procedure = FALSE,
                               include_eurovoc = FALSE,
                               include_directory_code = FALSE,
                               include_sector = FALSE,
                               aggregate_vars = NULL,
                               order = FALSE,
                               limit = NULL) {
  
  if (missing(resource_type)) stop("'resource_type' must be defined")
  
  if (!is.null(date_from) && !grepl("^\\d{4}-\\d{2}-\\d{2}$", date_from)){
    stop("'date_from' must be in YYYY-MM-DD format.", call. = TRUE)
  }
  if (!is.null(date_to) && !grepl("^\\d{4}-\\d{2}-\\d{2}$", date_to)){
    stop("'date_to' must be in YYYY-MM-DD format.", call. = TRUE)
  }
  
  # Kootaan mitkä kentät ovat aktiivisia - JÄRJESTYS TÄRKEÄ (vastaa vanhan funktion SELECT-järjestystä)
  include_flags <- c(
    celex = include_celex,
    date  = include_date || !is.null(date_from) || !is.null(date_to),
    force = include_force,
    eurovoc = include_eurovoc,
    court_procedure = include_court_procedure,
    ecli = include_ecli,
    author = include_author,
    directory_code = include_directory_code,
    sector = include_sector
  )
  
  active_fields <- names(include_flags)[include_flags]
  
  select_parts <- character(0)
  where_parts  <- character(0)
  group_vars   <- c("?work", "?type")
  
  for (field_name in active_fields) {
    
    spec <- field_specs[[field_name]]
    
    # yhteensopivuustarkistus
    if (!is.null(spec$incompatible_with) && resource_type %in% spec$incompatible_with) {
      stop(paste(field_name, "variable incompatible with requested resource type"), call. = TRUE)
    }
    
    is_aggregated <- field_name %in% aggregate_vars
    
    if (is_aggregated && !spec$aggregatable) {
      stop(paste0("'", field_name, "' cannot be aggregated."), call. = TRUE)
    }
    
    if (is_aggregated) {
      agg_parts <- vapply(spec$select_vars, function(v) {
        varname <- sub("^\\?", "", v)
        paste0('(group_concat(distinct ', v, ';separator="|") as ?', varname, ')')
      }, character(1))
      select_parts <- c(select_parts, agg_parts)
    } else {
      select_parts <- c(select_parts, spec$select_vars)
      group_vars <- c(group_vars, spec$select_vars)
    }
    
    where_parts <- c(where_parts, spec$where)
  }
  
  # ---- date_from / date_to erikoishaara ----
  # Jos annettu, date-kentän WHERE-lohko pitää korvata pakollisella + FILTER-lauseilla
  if (!is.null(date_from) || !is.null(date_to)) {
    
    date_filter <- "?work cdm:work_date_document ?date."
    if (!is.null(date_from)){
      date_filter <- paste(date_filter, paste0('FILTER(?date >= "', date_from, '"^^xsd:date)'))
    }
    if (!is.null(date_to)){
      date_filter <- paste(date_filter, paste0('FILTER(?date <= "', date_to, '"^^xsd:date)'))
    }
    
    # korvataan date-kentän alkuperäinen (OPTIONAL) where-lohko pakollisella versiolla
    date_idx <- which(active_fields == "date")
    if (length(date_idx) > 0) {
      where_parts[date_idx] <- date_filter
    }
  }
  
  use_group_by <- length(aggregate_vars) > 0
  
  select_stmt <- if (use_group_by) "select" else "select distinct"
  
  query <- paste(
    "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>
  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>
  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
  PREFIX dc:<http://purl.org/dc/elements/1.1/>
  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX owl:<http://www.w3.org/2002/07/owl#>",
    select_stmt, "?work ?type",
    paste(select_parts, collapse = " "),
    if (resource_type == "any") {
      "where{"
    } else {
      "where{ ?work cdm:work_has_resource-type ?type."
    }
  )
  
  # resource_type FILTER (kopioitu suoraan vanhasta funktiosta, vain directive esimerkkinä prototyypissa)
  # resource_type FILTER
  rt_filter <- get_resource_type_filter(resource_type, manual_type)
  if (!is.null(rt_filter)) {
    filter_sep <- if (resource_type == "manual") "" else " "
    query <- paste(query, rt_filter, sep = filter_sep)
  }
  
  query <- paste(query, "\n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>}")
  
  query <- paste(query, paste(where_parts, collapse = " "))
  
  query <- paste(query, 'FILTER not exists{?work cdm:do_not_index "true"^^<http://www.w3.org/2001/XMLSchema#boolean>}.')
  
  query <- paste(query, "}")
  
  if (use_group_by) {
    query <- paste(query, "GROUP BY", paste(group_vars, collapse = " "))
  }
  
  if (order == TRUE){
    order_var <- if (use_group_by) "?work" else "?date"
    query <- paste0(query, " order by str(", order_var, ")")
  }
  
  if (!is.null(limit) & is.integer(as.integer(limit))){
    query <- paste(query, "limit", limit, sep = " ")
  }
  
  return(query)
}