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
