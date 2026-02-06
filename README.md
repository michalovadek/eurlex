# eurlex: Retrieve Data on European Union Law <img src="man/figures/logo.png" align="right" width="140" />

<!-- badges: start -->
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/eurlex)](https://cran.r-project.org/package=eurlex)
[![CRAN_Downloads](https://cranlogs.r-pkg.org/badges/grand-total/eurlex)](https://cran.r-project.org/package=eurlex)
[![R-CMD-check](https://github.com/michalovadek/eurlex/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/michalovadek/eurlex/actions/workflows/check-standard.yaml)
<!-- badges: end -->

The `eurlex` R [package](https://michalovadek.github.io/eurlex/) reduces the overhead associated with using SPARQL and REST APIs made available by the EU Publication Office and other EU institutions. Compared to pure web-scraping, the package provides more efficient and transparent access to data on European Union laws and policies.

See the [vignette](https://michalovadek.github.io/eurlex/articles/eurlexpkg.html) for a basic walkthrough on how to use the package. Check function documentation for most up-to-date overview of features. Example use cases are shown in this [paper](https://www.tandfonline.com/doi/full/10.1080/2474736X.2020.1870150).

You can use `eurlex` to create automatically updated overviews of EU decision-making activity, as shown [here](https://michalovadek.github.io/eulaw/).

## Installation
Install from CRAN via `install.packages("eurlex")`.

The development version is available via `remotes::install_github("michalovadek/eurlex")`.

## Cite
Michal Ovádek (2021) **Facilitating access to data on European Union laws**, *Political Research Exchange*, 3:1, DOI: [10.1080/2474736X.2020.1870150](https://doi.org/10.1080/2474736X.2020.1870150)

``` r
@article{ovadek2021facilitating,
  author       = {Ovádek, Michal},
  title        = {Facilitating access to data on European Union laws},
  year         = {2021},
  journal      = {Political Research Exchange},
  volume       = {3},
  number       = {1},
  pages        = {Article No. 1870150},
  url          = {https://doi.org/10.1080/2474736X.2020.1870150}
}
```

## Basic usage
The `eurlex` package currently envisions the typical use-case to consist of getting bulk information about EU legislation into R as fast as possible. The package contains three core functions to achieve that objective: `elx_make_query()` to create pre-defined or customized SPARQL queries; `elx_run_query()` to execute the pre-made or any other manually input query; and `elx_fetch_data()` to fire GET requests for certain metadata to the REST API.

The function `elx_make_query` takes as its first argument the type of resource to be retrieved (such as "directive" or "any") from the semantic database that powers Eur-Lex (and other publications) called Cellar. If you are familiar with SPARQL, you can always specify your own queries and execute them with `elx_run_query()`.

`elx_run_query()` executes SPARQL queries on a pre-specified endpoint of the EU Publication Office. It outputs a `data.frame` where each column corresponds to one of the requested variables, while the rows accumulate observations of the resource type satisfying the query criteria. Obviously, the more data is to be returned, the longer the execution time, varying from a few seconds to several hours, depending also on your connection. The first column always contains the unique URI of a "work" (usually legislative act or court judgment) which identifies each resource in Cellar. Several human-readable identifiers are normally associated with each "work" but the most useful one tends to be [CELEX](https://eur-lex.europa.eu/content/tools/TableOfSectors/types_of_documents_in_eurlex.html), retrieved by default.

``` r
# load library
library(eurlex)

# create query
query <- elx_make_query("directive", include_date_transpos = TRUE)

# execute query
results <- elx_run_query(query)
```

One of the most useful things about the API is that we obtain a comprehensive list of identifiers that we can subsequently use to obtain more data relating to the document in question. While the results of the SPARQL queries can also be useful for web-scraping, the function `elx_fetch_data()` makes it possible to fire GET requests to retrieve data on documents with known identifiers (including Cellar URI). The function for example enables downloading the title and the full text of a document in all available languages.

## Note
This package nor its author are in any way affiliated with the EU, its institutions, offices or agencies. Please refer to the applicable [data reuse policies](https://eur-lex.europa.eu/content/welcome/data-reuse.html).

Please consider contributing to the maintenance and development of the package by reporting bugs or suggesting new features.

## Useful resources
Guide to CELEX numbers: https://eur-lex.europa.eu/content/tools/TableOfSectors/types_of_documents_in_eurlex.html

List of resource types in Cellar (NAL): http://publications.europa.eu/resource/authority/resource-type

NAL of corporate bodies:
http://publications.europa.eu/resource/authority/corporate-body

Query builder:
https://op.europa.eu/en/advanced-sparql-query-editor

Common data model:
https://op.europa.eu/en/web/eu-vocabularies/dataset/-/resource?uri=http://publications.europa.eu/resource/dataset/cdm

SPARQL endpoint:
http://publications.europa.eu/webapi/rdf/sparql
 
