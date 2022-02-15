# eurlex 0.4.1

## Major changes

- `elx_fetch_data(type = "notice", notice = c("tree","branch", "object"))` now mirrors the behaviour of `elx_download_xml()` but instead of saving to path givess access to XML notice in R

## Minor changes

- fixed bug in `elx_download_xml()` parameter checking
- `elx_download_xml(notice = "object")` now retrieves metadata correctly

# eurlex 0.4.0

## Major changes

- download XML notices associated with Cellar URLs with `elx_download_xml()`
- retrieve European Case Law Identifier (ECLI) with `elx_make_query(include_ecli = TRUE)`

## Minor changes

- host of smaller code improvements in `elx_fetch_data()`
- more consistent and strict error generation across all server-interacting functions
- started adding unit tests

# eurlex 0.3.6

## Major changes

- `elx_run_query()` now fails gracefully in presence of internet/server problems
- `elx_fetch_data()` now automatically fixes urls with parentheses (e.g. "32019H1115(01)" used to fail)

## Minor changes

- minor fixes to vignette
- `elx_parse_xml` no longer an exported function

# eurlex 0.3.5

## Major changes

- it is now possible to select all resource types available with `elx_make_query(resource_type = "any")`. Since there are nearly 1 million CELEX codes, use with discretion and expect long execution times
- results can be restricted to a particular directory code with `elx_make_query(directory = "18")` (directory code "18" denotes Common Foreign and Security Policy)
- results can be restricted to a particular sector with `elx_make_query(sector = 2)` (sector code 2 denotes EU international agreements)

## Minor changes

- new feature: request date of court case submission `elx_make_query(include_date_lodged = TRUE)`
- new feature: request type of court procedure and outcome `elx_make_query(include_court_procedure = TRUE)`
- new feature: request directory code of legal act `elx_make_query(include_directory = TRUE)`
- `elx_curia_list()` has a new default parameter `parse = TRUE` which creates separate columns for `ecli`, `see_case`, `appeal` applying regular expressions on `case_info`

# eurlex 0.3.4

## Major changes

- new feature: request citations referenced in target resource with elx_make_query(include_citations = TRUE); retrieved in CELEX form
- new feature: request document author(s) with `elx_make_query(include_author = TRUE)`
- XML parsing is now more efficient due to utilising (rather than stripping) namespaces (but still room for improvement)

## Minor changes

- fixed bug in elx_label_eurovoc whereby resulting data frames contained list-columns

# eurlex 0.3.3

## Minor changes

- hotfix for critical bug in xml parsing that scrambled column with legal basis where this was requested

# eurlex 0.3.2

## Major changes

- improvement to legal basis harvesting thanks to help from Eur-Lex insiders
- legal basis results are now slightly more comprehensive and correct
- legal basis results now include a new column detailing the "suffix" (paragraph, subparagraph, etc.) in string form

## Minor changes

- minor updates to documentation

# eurlex 0.3.1

## Minor changes

- `elx_fetch_data()` now prefers CELEX-based URLs (instead of Cellar URIs) as input, as they appear to yield fewer missing documents

# eurlex 0.3.0

## Major changes

- `elx_fetch_data("text")` now retrieves plain text from html, pdf and MS Word documents
- the type of source file is documented
- added handling of multiple files: all available text is retrieved and concatenated
- so far no support for images requiring OCR for text extraction for the sake of limiting dependencies and avoiding prolonging execution time

# eurlex 0.2.3

## Minor changes

- fixed serious bugs in `elx_curia_list()`
- fixed bug in `elx_label_eurovoc()`

# eurlex 0.2.2

## Major changes

- `elx_council_votes()` made fully operational

# eurlex 0.2.1

## Minor changes

- optimization, reducing dependencies, etc.

# eurlex 0.2.0

## Major changes

- addition of proposals and national implementing laws to possible SPARQL queries
- EuroVoc topics, retrievable in all EU languages, can now be included in SPARQL results
- new date options (force, end of validity, transposition)
- added `elx_curia_list()` to retrieve full list of EU court cases

## Minor changes

- switch from XML to xml2
- SPARQL package dependency removed
- cascading language options for `elx_fetch_data()`
