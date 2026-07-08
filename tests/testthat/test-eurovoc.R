testthat::test_that("eurovoc labels can be fetched", {
  
  testthat::skip_on_cran()
  
  out <- eurlex::elx_label_eurovoc(uri_eurovoc = "http://eurovoc.europa.eu/5760", 
                                   language = "fr")
  
  testthat::expect_equal(nrow(out), 1)
  testthat::expect_true("eurovoc" %in% names(out))
  testthat::expect_true("labels" %in% names(out))
  testthat::expect_equal(out$labels, "oiseau")
  
})

testthat::test_that("eurovoc labels work with multiple URIs", {
  
  testthat::skip_on_cran()
  
  out <- eurlex::elx_label_eurovoc(
    uri_eurovoc = c("http://eurovoc.europa.eu/5760", "http://eurovoc.europa.eu/1338"),
    language = "en"
  )
  
  testthat::expect_equal(nrow(out), 2)
  
})

testthat::test_that("eurovoc alt_labels parameter returns additional labels", {
  
  testthat::skip_on_cran()
  
  out <- eurlex::elx_label_eurovoc(
    uri_eurovoc = "http://eurovoc.europa.eu/5760",
    alt_labels = TRUE,
    language = "en"
  )
  
  # alt_labels should return more than one comma-separated label
  n_labels <- lengths(strsplit(out$labels, ","))
  
  testthat::expect_gt(n_labels, 1)
  
})