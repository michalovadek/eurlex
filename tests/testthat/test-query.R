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