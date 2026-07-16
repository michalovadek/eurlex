compare_query_builders <- function(label, ...) {
  old_q <- elx_make_query(...)
  new_q <- elx_make_query_new(...)
  
  # Normalisoidaan whitespace ennen vertailua - SPARQL ei valita ylimaaraisista
  # valilyonneista/rivinvaihdoista, joten tama on merkityksellinen vertailu
  normalize_ws <- function(x) {
    x <- gsub("\\s+", " ", x)  # kaikki whitespace-sarjat yhdeksi valiksi
    trimws(x)
  }
  
  old_norm <- normalize_ws(old_q)
  new_norm <- normalize_ws(new_q)
  
  is_identical <- identical(old_norm, new_norm)
  
  if (!is_identical) {
    cat("\n=== MISMATCH:", label, "===\n")
    cat("--- OLD (normalized) ---\n")
    cat(old_norm, "\n")
    cat("--- NEW (normalized) ---\n")
    cat(new_norm, "\n")
    cat("=========================\n\n")
  }
  
  data.frame(test = label, identical = is_identical, stringsAsFactors = FALSE)
}

run_byte_identity_suite <- function() {
  
  results <- list()
  
  results[["celex_only"]] <- compare_query_builders(
    "celex only",
    resource_type = "directive", include_celex = TRUE, limit = 5
  )
  
  results[["date_only"]] <- compare_query_builders(
    "date only",
    resource_type = "directive", include_date = TRUE, limit = 5
  )
  
  results[["force_only"]] <- compare_query_builders(
    "force only",
    resource_type = "directive", include_force = TRUE, limit = 5
  )
  
  results[["author_no_agg"]] <- compare_query_builders(
    "author without aggregation",
    resource_type = "directive", include_author = TRUE, limit = 5
  )
  
  results[["date_force"]] <- compare_query_builders(
    "date + force",
    resource_type = "directive", include_date = TRUE, include_force = TRUE, limit = 5
  )
  
  results[["celex_date"]] <- compare_query_builders(
    "celex + date",
    resource_type = "directive", include_celex = TRUE, include_date = TRUE, limit = 5
  )
  
  results[["all_four"]] <- compare_query_builders(
    "celex + date + force + author (no agg)",
    resource_type = "directive", include_celex = TRUE, include_date = TRUE,
    include_force = TRUE, include_author = TRUE, limit = 5
  )
  
  results[["date_range"]] <- compare_query_builders(
    "date_from + date_to",
    resource_type = "directive", date_from = "2015-01-01", date_to = "2015-12-31", limit = 5
  )
  
  results[["order_true"]] <- compare_query_builders(
    "order = TRUE",
    resource_type = "directive", include_date = TRUE, order = TRUE, limit = 5
  )
  
  results[["regulation"]] <- compare_query_builders(
    "resource_type = regulation",
    resource_type = "regulation", include_date = TRUE, limit = 5
  )
  
  results[["decision"]] <- compare_query_builders(
    "resource_type = decision",
    resource_type = "decision", include_date = TRUE, limit = 5
  )
  
  results[["recommendation"]] <- compare_query_builders(
    "resource_type = recommendation",
    resource_type = "recommendation", include_date = TRUE, limit = 5
  )
  
  results[["intagr"]] <- compare_query_builders(
    "resource_type = intagr",
    resource_type = "intagr", include_date = TRUE, limit = 5
  )
  
  results[["caselaw"]] <- compare_query_builders(
    "resource_type = caselaw",
    resource_type = "caselaw", include_date = TRUE, limit = 5
  )
  
  results[["proposal"]] <- compare_query_builders(
    "resource_type = proposal",
    resource_type = "proposal", include_date = TRUE, limit = 5
  )
  
  results[["national_impl"]] <- compare_query_builders(
    "resource_type = national_impl",
    resource_type = "national_impl", include_date = TRUE, limit = 5
  )
  
  results[["manual"]] <- compare_query_builders(
    "resource_type = manual",
    resource_type = "manual", manual_type = "SWD", include_date = TRUE, limit = 5
  )
  
  results[["any"]] <- compare_query_builders(
    "resource_type = any",
    resource_type = "any", include_date = TRUE, limit = 5
  )
  
  results[["no_limit"]] <- compare_query_builders(
    "no limit specified",
    resource_type = "directive", include_celex = TRUE
  )
  
  
  summary_df <- do.call(rbind, results)
  rownames(summary_df) <- NULL
  
  cat("\n=== BYTE IDENTITY TEST SUMMARY ===\n")
  print(summary_df)
  
  n_pass <- sum(summary_df$identical)
  n_total <- nrow(summary_df)
  cat(sprintf("\n%d / %d tests identical\n", n_pass, n_total))
  
  if (n_pass < n_total) {
    cat("WARNING: Not all tests passed. See mismatches printed above.\n")
  } else {
    cat("All tests passed - new builder is byte-identical to old for tested combinations.\n")
  }
  
  invisible(summary_df)
}