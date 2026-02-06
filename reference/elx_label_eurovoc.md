# Label EuroVoc concepts

Create a look-up table with labels for EuroVoc concept URIs. Only unique
identifiers are returned.

## Usage

``` r
elx_label_eurovoc(uri_eurovoc = "", alt_labels = FALSE, language = "en")
```

## Arguments

- uri_eurovoc:

  Character vector with valid EuroVoc URIs

- alt_labels:

  If `TRUE`, results include comma-separated alternative labels in
  addition to the preferred label

- language:

  Language in which to return the labels, in ISO 639 2-char code

## Value

A data frame containing EuroVoc unique concept identifiers and labels.

## Examples

``` r
# \donttest{
elx_label_eurovoc(uri_eurovoc = "http://eurovoc.europa.eu/5760", language = "fr")
#>                         eurovoc labels
#> 1 http://eurovoc.europa.eu/5760 oiseau
# }
```
