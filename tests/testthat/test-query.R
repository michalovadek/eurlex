testthat::test_that("queries can be made", {
  
  testthat::skip_on_cran()
  
  q <- eurlex::elx_make_query("directive")
  
  testthat::expect_gt(nchar(q), 800)
  
})
