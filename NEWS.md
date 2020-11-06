# eurlex 0.3.4

## Major changes

- new feature: request citations referenced in target resource with elx_make_query(include_citations = TRUE); retrieved in CELEX form
- new feature: request document author(s) with elx_make_query(include_author = TRUE)

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
