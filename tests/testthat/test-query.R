testthat::test_that("queries can be made", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query("directive")
  
  testthat::expect_gt(nchar(q), 800)
  
})

testthat::test_that("national_impl query has balanced parentheses", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query("national_impl")
  
  n_open <- lengths(regmatches(q, gregexpr("\\(", q)))
  n_close <- lengths(regmatches(q, gregexpr("\\)", q)))
  
  testthat::expect_equal(n_open, n_close)
  
})

testthat::test_that("national_impl query is well-formed", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query("national_impl")
  
  testthat::expect_gt(nchar(q), 800)
  testthat::expect_true(grepl("MEAS_NATION_IMPL", q))
  
})

testthat::test_that("include_title returns document titles", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_title = TRUE, 
                              limit = 5)
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_true("title" %in% names(out))
  testthat::expect_true(all(nchar(out$title) > 10))
  
})

testthat::test_that("include_title works alongside other include parameters", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_title = TRUE, 
                              include_date = TRUE,
                              include_author = TRUE,
                              limit = 5)
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_true(all(c("title", "date", "author") %in% names(out)))
  testthat::expect_equal(nrow(out), 5)
  
})

testthat::test_that("date_from and date_to filter results correctly", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              date_from = "2015-01-01", 
                              date_to = "2015-12-31",
                              limit = 5)
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_true(all(out$date >= "2015-01-01"))
  testthat::expect_true(all(out$date <= "2015-12-31"))
  
})

testthat::test_that("date_from and date_to validate format", {
  
  testthat::expect_error(
    eurlex::elx_make_query(resource_type = "directive", date_from = "2015/01/01"),
    "must be in YYYY-MM-DD format"
  )
  
  testthat::expect_error(
    eurlex::elx_make_query(resource_type = "directive", date_to = "15-01-2015"),
    "must be in YYYY-MM-DD format"
  )
  
})

testthat::test_that("include_date still works without date_from/date_to", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", include_date = TRUE)
  
  testthat::expect_true(grepl("OPTIONAL\\{\\?work cdm:work_date_document \\?date\\.\\}", q))
  
})


testthat::test_that("include_author combines multiple authors without duplicating rows", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_author = TRUE, 
                              limit = 2000)
  
  out <- eurlex::elx_run_query(q)
  
  # No document should appear more than once
  testthat::expect_true(all(table(out$work) == 1))
  
})

testthat::test_that("include_author correctly concatenates known multi-author document", {
  
  testthat::skip_on_cran()
  
  q <- '
  PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>
  PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
  SELECT ?work (group_concat(distinct ?author;separator="|") as ?author) WHERE {
    VALUES ?work { <http://publications.europa.eu/resource/cellar/01d3846d-ff64-4190-a1bd-39abf9673281> }
    OPTIONAL{
      ?work cdm:work_created_by_agent ?authorx.
      ?authorx skos:prefLabel ?author. 
      FILTER(lang(?author)="en")
    }
  }
  GROUP BY ?work
  '
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_equal(nrow(out), 1)
  testthat::expect_true(grepl("Council of the European Union", out$author))
  testthat::expect_true(grepl("European Parliament", out$author))
  
})

testthat::test_that("include_author works combined with other include parameters", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_author = TRUE, 
                              include_date = TRUE,
                              include_force = TRUE,
                              limit = 5)
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_true(all(c("author", "date", "force") %in% names(out)))
  testthat::expect_equal(nrow(out), 5)
  
})

testthat::test_that("order = TRUE works correctly with include_author", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_author = TRUE, 
                              order = TRUE,
                              limit = 5)
  
  out <- eurlex::elx_run_query(q)
  
  testthat::expect_equal(nrow(out), 5)
  
})

testthat::test_that("include_author does not affect queries without it (regression)", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query(resource_type = "directive", 
                              include_date = TRUE, 
                              include_force = TRUE, 
                              limit = 5)
  
  testthat::expect_true(grepl("select distinct", q))
  testthat::expect_false(grepl("GROUP BY", q))
  
  out <- eurlex::elx_run_query(q)
  testthat::expect_equal(nrow(out), 5)
  
})
