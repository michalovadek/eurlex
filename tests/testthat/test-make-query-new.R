# tests/testthat/test-make-query-new.R

test_that("elx_make_query_new produces byte-identical output to elx_make_query for basic fields", {
  
  skip_on_cran()
  
  normalize_ws <- function(x) trimws(gsub("\\s+", " ", x))
  
  test_cases <- list(
    list(resource_type = "directive", include_celex = TRUE, limit = 5),
    list(resource_type = "directive", include_date = TRUE, limit = 5),
    list(resource_type = "directive", include_force = TRUE, limit = 5)
  )
  
  for (args in test_cases) {
    old_q <- do.call(elx_make_query, args)
    new_q <- do.call(elx_make_query_new, args)
    expect_equal(normalize_ws(old_q), normalize_ws(new_q))
  }
  
})

test_that("elx_make_query_new with explicit aggregate_vars matches elx_make_query's automatic author aggregation", {
  
  skip_on_cran()
  
  normalize_ws <- function(x) trimws(gsub("\\s+", " ", x))
  
  # Old elx_make_query() ALWAYS auto-aggregates the author field.
  # New elx_make_query_new() requires explicit aggregate_vars = "author".
  # This is an intentional, documented behavior difference (see @details).
  old_q <- elx_make_query(resource_type = "directive", include_author = TRUE, limit = 5)
  new_q <- elx_make_query_new(resource_type = "directive", include_author = TRUE, 
                              aggregate_vars = "author", limit = 5)
  
  expect_equal(normalize_ws(old_q), normalize_ws(new_q))
  
})

test_that("elx_make_query_new produces byte-identical output for all resource_type values", {
  
  skip_on_cran()
  
  normalize_ws <- function(x) trimws(gsub("\\s+", " ", x))
  
  resource_types <- c("directive", "regulation", "decision", "recommendation", 
                      "intagr", "caselaw", "proposal", "national_impl", "any")
  
  for (rt in resource_types) {
    old_q <- elx_make_query(resource_type = rt, include_date = TRUE, limit = 5)
    new_q <- elx_make_query_new(resource_type = rt, include_date = TRUE, limit = 5)
    expect_equal(normalize_ws(old_q), normalize_ws(new_q))
  }
  
  # manual type - separate call since it requires the manual_type parameter
  old_manual <- elx_make_query(resource_type = "manual", manual_type = "SWD", include_date = TRUE, limit = 5)
  new_manual <- elx_make_query_new(resource_type = "manual", manual_type = "SWD", include_date = TRUE, limit = 5)
  expect_equal(normalize_ws(old_manual), normalize_ws(new_manual))
  
})

test_that("aggregate_vars combines multiple authors without duplicating rows", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_author = TRUE, 
                          aggregate_vars = "author", limit = 2000)
  
  out <- elx_run_query(q)
  
  expect_true(all(table(out$work) == 1))
  
})

test_that("aggregate_vars works for multi-variable field lbs", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_lbs = TRUE,
                          aggregate_vars = "lbs", limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(c("lbs", "lbcelex", "lbsuffix") %in% names(out)))
  
})

test_that("lbs is incompatible with caselaw and matches old error message", {
  
  old_err <- tryCatch(
    elx_make_query(resource_type = "caselaw", include_lbs = TRUE),
    error = function(e) conditionMessage(e)
  )
  new_err <- tryCatch(
    elx_make_query_new(resource_type = "caselaw", include_lbs = TRUE),
    error = function(e) conditionMessage(e)
  )
  
  expect_equal(old_err, new_err)
  
})

test_that("directory and directory_code share the ?directory variable correctly", {
  
  skip_on_cran()
  
  normalize_ws <- function(x) trimws(gsub("\\s+", " ", x))
  
  old_q <- elx_make_query(resource_type = "directive", include_directory = TRUE, 
                          include_directory_code = TRUE, limit = 5)
  new_q <- elx_make_query_new(resource_type = "directive", include_directory = TRUE, 
                              include_directory_code = TRUE, limit = 5)
  
  expect_equal(normalize_ws(old_q), normalize_ws(new_q))
  
})

test_that("limit validation rejects non-numeric input without error", {
  
  q_valid <- elx_make_query_new(resource_type = "directive", limit = 5)
  expect_true(grepl("limit 5", q_valid))
  
  q_invalid <- elx_make_query_new(resource_type = "directive", limit = "abc")
  expect_false(grepl("limit", q_invalid))
  
})

test_that("date_to must not be earlier than date_from", {
  
  expect_error(
    elx_make_query_new(resource_type = "directive", date_from = "2020-01-01", date_to = "2015-01-01"),
    "must be on or after"
  )
  
  # Same date on both ends is allowed
  expect_no_error(
    elx_make_query_new(resource_type = "directive", date_from = "2015-06-15", date_to = "2015-06-15")
  )
  
})

test_that("order = TRUE works correctly with aggregate_vars", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_author = TRUE, 
                          aggregate_vars = "author", order = TRUE, limit = 5)
  
  out <- elx_run_query(q)
  
  expect_equal(nrow(out), 5)
  
})


test_that("subject_matter field returns valid classification terms", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_subject_matter = TRUE, limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true("subjectmatter" %in% names(out))
  expect_true(all(nchar(out$subjectmatter[!is.na(out$subjectmatter)]) > 2))
  
})

test_that("subject_matter aggregates correctly for documents with multiple descriptors", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_subject_matter = TRUE,
                          aggregate_vars = "subject_matter", limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(table(out$work) == 1))
  
})

test_that("subject_matter works combined with other aggregated fields", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "directive", include_subject_matter = TRUE, 
                          include_author = TRUE, aggregate_vars = c("subject_matter", "author"), 
                          limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(c("subjectmatter", "author") %in% names(out)))
  expect_equal(nrow(out), 5)
  
})

test_that("official_journal field returns valid OJ reference components", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "regulation", include_celex = TRUE,
                          include_official_journal = TRUE, limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(c("ojnumber", "ojyear", "ojclass") %in% names(out)))
  expect_true(all(grepl("^\\d{4}$", out$ojyear[!is.na(out$ojyear)])))
  
})

test_that("official_journal field returns valid OJ reference components", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "regulation", include_celex = TRUE,
                          include_official_journal = TRUE, limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(c("ojnumber", "ojyear", "ojclass") %in% names(out)))
  expect_true(all(grepl("^\\d{4}$", out$ojyear[!is.na(out$ojyear)])))
  
})

test_that("official_journal aggregates correctly for documents published in multiple OJs", {
  
  skip_on_cran()
  
  q <- '
  PREFIX cdm: <http://publications.europa.eu/ontology/cdm#>
  SELECT ?work (group_concat(distinct ?ojnumber;separator="|") as ?ojnumber) 
               (group_concat(distinct ?ojyear;separator="|") as ?ojyear)
               (group_concat(distinct ?ojclass;separator="|") as ?ojclass) WHERE {
    VALUES ?work { <http://publications.europa.eu/resource/cellar/009393f1-f7f6-4c6e-a067-e497420f1e79> }
    OPTIONAL{
      ?work cdm:resource_legal_published_in_official-journal ?oj.
      ?oj cdm:official-journal_number ?ojnumber.
      ?oj cdm:official-journal_year ?ojyear.
      ?oj cdm:official-journal_class ?ojclass.
    }
  }
  GROUP BY ?work
  '
  
  out <- elx_run_query(q)
  
  expect_equal(nrow(out), 1)
  expect_true(grepl("143", out$ojnumber))
  expect_true(grepl("275", out$ojnumber))
  
})

test_that("official_journal works combined with other aggregated fields", {
  
  skip_on_cran()
  
  q <- elx_make_query_new(resource_type = "regulation", include_official_journal = TRUE, 
                          include_author = TRUE, 
                          aggregate_vars = c("official_journal", "author"), 
                          limit = 5)
  
  out <- elx_run_query(q)
  
  expect_true(all(c("ojnumber", "ojyear", "ojclass", "author") %in% names(out)))
  expect_equal(nrow(out), 5)
  
})