testthat::test_that("elx_download_xml downloads object notice", {
  
  testthat::skip_on_cran()
  
  temploc <- file.path(tempdir(), "elxnotice_object.xml")
  on.exit(unlink(temploc))
  
  result <- eurlex::elx_download_xml(
    url = "http://publications.europa.eu/resource/celex/32022D0154",
    file = temploc, 
    notice = "object"
  )
  
  testthat::expect_true(file.exists(temploc))
  testthat::expect_gt(file.size(temploc), 1000)
  
})

testthat::test_that("elx_download_xml downloads tree notice", {
  
  testthat::skip_on_cran()
  
  temploc <- file.path(tempdir(), "elxnotice_tree.xml")
  on.exit(unlink(temploc))
  
  result <- eurlex::elx_download_xml(
    url = "http://publications.europa.eu/resource/celex/32022D0154",
    file = temploc, 
    notice = "tree"
  )
  
  testthat::expect_true(file.exists(temploc))
  testthat::expect_gt(file.size(temploc), 1000)
  
})

testthat::test_that("elx_download_xml validates notice argument", {
  
  testthat::expect_error(
    eurlex::elx_download_xml(
      url = "http://publications.europa.eu/resource/celex/32022D0154",
      file = tempfile(),
      notice = "invalid_type"
    ),
    "notice type must be correctly specified"
  )
  
})

testthat::test_that("elx_download_xml requires url and notice", {
  
  testthat::expect_error(
    eurlex::elx_download_xml(notice = "object"),
    "url must be specified"
  )
  
  testthat::expect_error(
    eurlex::elx_download_xml(url = "http://example.com"),
    "notice type must be specified"
  )
  
})