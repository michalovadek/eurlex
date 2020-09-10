# eurlex 0.3.0

## Major changes

- `elx_fetch_data("text")` now retrieves plain text from html, pdf and MS Word documents
- the type of source file is documented
- added handling of multiple files: all available text is retrieved and concatenated
- so far no support for images requiring OCR for text extraction for the sake of limiting dependencies and avoiding prolonging execution time

# eurlex 0.2.3

## Minor changes

- fixed serious bugs in `elx_curia_list()`

# eurlex 0.2.2

## Major changes

- `elx_council_votes()` made fully operational

# eurlex 0.2.1

## Minor changes

- optimization, reduce dependencies, switch from XML to xml2, etc.