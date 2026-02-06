# Execute SPARQL queries

Executes cURL request to a pre-defined endpoint of the EU Publications
Office. Relies on elx_make_query to generate valid SPARQL queries.
Results are capped at 1 million rows.

## Usage

``` r
elx_run_query(
  query = "",
  endpoint = "http://publications.europa.eu/webapi/rdf/sparql"
)
```

## Arguments

- query:

  A valid SPARQL query specified by
  [`elx_make_query()`](https://michalovadek.github.io/eurlex/reference/elx_make_query.md)
  or manually

- endpoint:

  SPARQL endpoint

## Value

A data frame containing the results of the SPARQL query. Column `work`
contains the Cellar URI of the resource.

## Examples

``` r
# \donttest{
elx_run_query(elx_make_query("directive", include_force = TRUE, limit = 10))
#>                                    work type      celex force
#> 1  469391ea-6c79-4680-84aa-c33db274e271  DIR 31979L0173 false
#> 5  e8fcaf0d-443a-40ec-b778-34b7d895d334  DIR 31989L0194 false
#> 9  52639f5f-ecaf-4f99-b633-e954cea5c8f3  DIR 31984L0378 false
#> 13 c7560407-689b-4752-9fb0-d0624ed83a19  DIR 31966L0683  true
#> 17 803aa7a4-5a22-493a-ae02-eb2751bff578  DIR 31993L0004 false
#> 21 a9ab7f4b-0630-49f4-b6e1-2a92c635fefa  DIR 31992L0017 false
#> 25 d83c00d6-9467-4e42-ad8b-5fcf1af66850  DIR 31983L0447 false
#> 29 311441f3-7879-4769-83c0-a6cb666d706f  DIR 31966L0162 false
#> 33 eebd7224-5f8b-4031-99dd-c81c720fa718  DIR 31974L0508 false
#> 37 f2e14ae4-6baf-407d-a66f-438373370239  DIR 31982L0957 false
# }
```
