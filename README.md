# eurlex <img src="man/figures/logo.png" align="right" width="120" />
An R package for retrieving official data on European Union law.

## Installation
The package is for the moment not available on CRAN. Install via `remotes::install_github("michalovadek/eurlex")`.

## Usage

The `eurlex` R package attempts to significantly reduce the overhead associated with using SPARQL and REST APIs made available by the EU Publication Office. Although at present it does not offer access to the same array of information as comprehensive web scraping might, the package provides simpler, more efficient and transparent access to data on European Union law.

The `eurlex` package currently envisions the typical use-case to consist of getting bulk information about EU legislation into R as fast as possible. The package contains three core functions to achieve that objective: `elx_make_query()` to create pre-defined or customized SPARQL queries; `elx_run_query()` to execute the pre-made or any other manually input query; and `elx_fetch_data()` to fire GET requests for certain metadata to the REST API.

The function `elx_make_query` takes as its first argument the type of resource to be retrieved (such as "directive") from the semantic database that powers Eur-Lex (and other publications) called Cellar. If you are familiar with SPARQL, you can always specify your own queries and execute them with `elx_run_query()`.

`elx_run_query()` executes SPARQL queries on a pre-specified endpoint of the EU Publication Office. It outputs a `data.frame` where each column corresponds to one of the requested variables, while the rows accumulate observations of the resource type satisfying the query criteria. Obviously, the more data is to be returned, the longer the execution time, varying from a few seconds to several minutes, depending also on your connection. The first column always contains the unique URI of a "work" (legislative act or court judgment) which identifies each resource in Cellar. Several human-readable identifiers are normally associated with each "work" but the most useful one is CELEX, retrieved by default.

The core contribution of the SPARQL requests is that we obtain a comprehensive list of identifiers that we can subsequently use to obtain more data relating to the document in question. While the results of the SPARQL queries are useful also for webscraping (with the `rvest` package), the function `elx_fetch_data()` enables us to fire GET requests to retrieve data on documents with known identifiers (including Cellar URI). The function currently enables downloading the title and the full text (where available in html) of a document.

See the [vignette](https://michalovadek.github.io/eurlex/articles/eurlexpkg.html) for a walkthrough on how to use the package.

## Cite
Michal Ovádek (2020). eurlex: An R package for retrieving official data on European Union law

## Note
This package nor its author are in any way affiliated with the EU Publications Office. Please refer to the applicable [data reuse policies](https://eur-lex.europa.eu/content/welcome/data-reuse.html).

## Useful resources
Guide to CELEX numbers: https://eur-lex.europa.eu/content/tools/TableOfSectors/types_of_documents_in_eurlex.html

List of resource types in Cellar: http://publications.europa.eu/resource/authority/resource-type

Indexation of data in Cellar: http://publications.europa.eu/resource/cellar/4874abcd-286a-11e8-b5fe-01aa75ed71a1.0001.03/DOC_1
