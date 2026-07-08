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
#> 1  0d76f53e-267f-495c-9854-15e8c3ee05c5  DIR 31965L0066 false
#> 5  47ba284d-04b9-11e3-a352-01aa75ed71a1  DIR 32013L0038  true
#> 9  899b6c44-84ec-11e4-91cd-01aa75ed71a1  DIR 32014L0107  true
#> 13 931d7a62-e01e-4f41-a318-a048818fc71d  DIR 31985L0346 false
#> 17 9e1d16c5-8aef-42ee-874c-283a182c49a9  DIR 31974L0394 false
#> 21 a5d0648f-2957-11e6-b616-01aa75ed71a1  DIR 32016L0882  true
#> 25 be551f62-20ea-411c-ab0f-72439b88517a  DIR 32007L0073 false
#> 29 da1ee45a-db1d-4e03-b225-f0fc3a3b5bff  DIR 32006L0055  true
#> 33 e0a6d9cf-a872-4f47-b96b-4995388046db  DIR 31976L0462 false
#> 37 e654bd63-1633-48eb-a33e-5e81b34ace7b  DIR 31992L0109 false
# }
```
