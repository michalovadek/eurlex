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
