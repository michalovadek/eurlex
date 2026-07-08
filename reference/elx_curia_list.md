# Scrape list of court cases from Curia

Harvests data from lists of EU court cases from curia.europa.eu. CELEX
identifiers are extracted from hyperlinks where available.

## Usage

``` r
elx_curia_list(
  data = c("all", "ecj_old", "ecj_new", "gc_all", "cst_all"),
  parse = TRUE
)
```

## Arguments

- data:

  Data to be scraped from four separate lists of cases maintained by
  Curia, defaults to "all" which contains cases from Court of Justice,
  General Court and Civil Service Tribunal.

- parse:

  If `TRUE`, references to cases and appeals are parsed out from
  `case_info` into separate columns

## Value

A data frame containing case identifiers and information as character
columns. Where the case id contains a hyperlink to Eur-Lex, the CELEX
identifier is retrieved as well. Hyperlinks to Eur-Lex disappeared from
more recent cases.

## Examples

``` r
if (FALSE) { # \dontrun{
elx_curia_list(data = "cst_all", parse = FALSE)
} # }
```
