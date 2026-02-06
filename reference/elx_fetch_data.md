# Retrieve additional data on EU documents

Get titles, texts, identifiers and XML notices for EU resources.

## Usage

``` r
elx_fetch_data(
  url,
  type = c("title", "text", "ids", "notice"),
  notice = c("tree", "branch", "object"),
  language_1 = "en",
  language_2 = "fr",
  language_3 = "de",
  include_breaks = TRUE,
  html_text = c("text2", "text")
)
```

## Arguments

- url:

  A valid url as character vector of length one based on a resource
  identifier such as CELEX or Cellar URI.

- type:

  The type of data to be retrieved. When type = "text", the returned
  list contains named elements reflecting the source of each text. When
  type = "notice", the results return an XML notice associated with the
  url.

- notice:

  If type = "notice", controls what kind of metadata are returned by the
  notice.

- language_1:

  The priority language in which the data will be attempted to be
  retrieved, in ISO 639 2-char code

- language_2:

  If data not available in `language_1`, try `language_2`

- language_3:

  If data not available in `language_2`, try `language_3`

- include_breaks:

  If TRUE, text includes tags showing where pages ("—pagebreak—", for
  pdfs) and documents ("—documentbreak—") were concatenated

- html_text:

  Choose whether to read text from html using
  [`rvest::html_text2()`](https://rvest.tidyverse.org/reference/html_text.html)
  ("text2") or
  [`rvest::html_text()`](https://rvest.tidyverse.org/reference/html_text.html)
  ("text")

## Value

A character vector of length one containing the result. When
`type = "text"`, named character vector where the name contains the
source of the text.

## Examples

``` r
# \donttest{
elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32014R0001", type = "title")
#> [1] "Commission Delegated Regulation (EU) No 1/2014 of 28 August 2013 establishing Annex III to Regulation (EU) No 978/2012 of the European Parliament and of the Council applying a scheme of generalised tariff preferences"
# }
```
