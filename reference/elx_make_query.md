# Create SPARQL queries

Generates pre-defined or manual SPARQL queries to retrieve document ids
from Cellar. List of available resource types:
http://publications.europa.eu/resource/authority/resource-type . Note
that not all resource types are compatible with default parameter
values.

## Usage

``` r
elx_make_query(
  resource_type = c("any", "directive", "regulation", "decision", "recommendation",
    "intagr", "caselaw", "manual", "proposal", "national_impl"),
  manual_type = "",
  directory = NULL,
  sector = NULL,
  include_corrigenda = FALSE,
  include_celex = TRUE,
  include_lbs = FALSE,
  include_date = FALSE,
  include_date_force = FALSE,
  include_date_endvalid = FALSE,
  include_date_transpos = FALSE,
  include_date_lodged = FALSE,
  include_force = FALSE,
  include_eurovoc = FALSE,
  include_citations = FALSE,
  include_citations_detailed = FALSE,
  include_author = FALSE,
  include_directory = FALSE,
  include_directory_code = FALSE,
  include_sector = FALSE,
  include_ecli = FALSE,
  include_court_procedure = FALSE,
  include_judge_rapporteur = FALSE,
  include_advocate_general = FALSE,
  include_court_formation = FALSE,
  include_court_scholarship = FALSE,
  include_court_origin = FALSE,
  include_original_language = FALSE,
  include_proposal = FALSE,
  order = FALSE,
  limit = NULL
)
```

## Arguments

- resource_type:

  Type of resource to be retrieved via SPARQL query

- manual_type:

  Define manually the type of resource to be retrieved

- directory:

  Restrict the results to a given directory code

- sector:

  Restrict the results to a given sector code

- include_corrigenda:

  If `TRUE`, results include corrigenda

- include_celex:

  If `TRUE`, results include CELEX identifier for each resource URI

- include_lbs:

  If `TRUE`, results include legal bases of legislation

- include_date:

  If `TRUE`, results include document date

- include_date_force:

  If `TRUE`, results include date of entry into force

- include_date_endvalid:

  If `TRUE`, results include date of end of validity

- include_date_transpos:

  If `TRUE`, results include date of transposition deadline for
  directives

- include_date_lodged:

  If `TRUE`, results include date a court case was lodged with the court

- include_force:

  If `TRUE`, results include whether legislation is in force

- include_eurovoc:

  If `TRUE`, results include EuroVoc descriptors of subject matter

- include_citations:

  If `TRUE`, results include citations (CELEX-labelled)

- include_citations_detailed:

  If `TRUE`, results include citations (CELEX-labelled) with additional
  details

- include_author:

  If `TRUE`, results include document author(s)

- include_directory:

  If `TRUE`, results include the label of the Eur-Lex directory code

- include_directory_code:

  If `TRUE`, results include the Eur-Lex directory code

- include_sector:

  If `TRUE`, results include the Eur-Lex sector code

- include_ecli:

  If `TRUE`, results include the ECLI identifier for court documents

- include_court_procedure:

  If `TRUE`, results include type of court procedure and outcome

- include_judge_rapporteur:

  If `TRUE`, results include the Judge-Rapporteur

- include_advocate_general:

  If `TRUE`, results include the Advocate General

- include_court_formation:

  If `TRUE`, results include the court formation

- include_court_scholarship:

  If `TRUE`, results include court-curated relevant scholarship

- include_court_origin:

  If `TRUE`, results include country of origin of court case

- include_original_language:

  If `TRUE`, results include authentic language of document (usually
  case)

- include_proposal:

  If `TRUE`, results include the CELEX of the proposal of the adopted
  legal act

- order:

  Order results by ids

- limit:

  Limit the number of results, for testing purposes mainly

## Value

A character string containing the SPARQL query

## Examples

``` r
elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE)
#> [1] "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>\n  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>\n  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>\n  PREFIX dc:<http://purl.org/dc/elements/1.1/>\n  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>\n  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n  PREFIX owl:<http://www.w3.org/2002/07/owl#>\n  select distinct ?work ?type ?celex ?date ?force where{ ?work cdm:work_has_resource-type ?type. FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DIR>||\n  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL>||\n  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL>) \n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>} OPTIONAL{?work cdm:resource_legal_id_celex ?celex.} OPTIONAL{?work cdm:work_date_document ?date.} OPTIONAL{?work cdm:resource_legal_in-force ?force.} FILTER not exists{?work cdm:do_not_index \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean>}. }"
elx_make_query(resource_type = "regulation", include_corrigenda = TRUE, order = TRUE)
#> [1] "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>\n  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>\n  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>\n  PREFIX dc:<http://purl.org/dc/elements/1.1/>\n  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>\n  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n  PREFIX owl:<http://www.w3.org/2002/07/owl#>\n  select distinct ?work ?type ?celex where{ ?work cdm:work_has_resource-type ?type. FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/REG>||\n  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL>||\n  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_FINANC>||\n  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL>) OPTIONAL{?work cdm:resource_legal_id_celex ?celex.} FILTER not exists{?work cdm:do_not_index \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean>}. } order by str(?date)"
elx_make_query(resource_type = "any", sector = 2)
#> [1] "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>\n  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>\n  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>\n  PREFIX dc:<http://purl.org/dc/elements/1.1/>\n  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>\n  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n  PREFIX owl:<http://www.w3.org/2002/07/owl#>\n  select distinct ?work ?type ?celex where{\n    ?work cdm:resource_legal_id_sector ?sector.\n    FILTER(str(?sector)='2')\n     \n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>} OPTIONAL{?work cdm:resource_legal_id_celex ?celex.} FILTER not exists{?work cdm:do_not_index \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean>}. }"
elx_make_query(resource_type = "manual", manual_type = "SWD")
#> [1] "PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>\n  PREFIX annot: <http://publications.europa.eu/ontology/annotation#>\n  PREFIX skos:<http://www.w3.org/2004/02/skos/core#>\n  PREFIX dc:<http://purl.org/dc/elements/1.1/>\n  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>\n  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n  PREFIX owl:<http://www.w3.org/2002/07/owl#>\n  select distinct ?work ?type ?celex where{ ?work cdm:work_has_resource-type ?type.FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/SWD>) \n FILTER not exists{?work cdm:work_has_resource-type <http://publications.europa.eu/resource/authority/resource-type/CORRIGENDUM>} OPTIONAL{?work cdm:resource_legal_id_celex ?celex.} FILTER not exists{?work cdm:do_not_index \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean>}. }"
```
