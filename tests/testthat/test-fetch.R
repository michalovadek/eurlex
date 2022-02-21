testthat::test_that("fetching data works", {
  
  testthat::skip_on_cran()
  
  out <- eurlex::elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32014R0001",
                                type = "notice",
                                notice = "branch")
  
  testthat::expect_gt(nchar(as.character(out)), 1000)
  
})
