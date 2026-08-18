# ============================================================
# Scenario: Data Validation Checks (Log-Check Macro, Reinterpreted)
# ============================================================
#
# Purpose: A dataset needs to be checked against a set of structural
# expectations (no missing keys, unique sequence numbers, valid dates)
# before it's trusted downstream. This runs all such checks at once
# and reports every failure found, not just the first one.
#
# --- Original SAS logic --------------------------------------
# %INCLUDE "&_project.programs\global\zmsaslogcheck.sas";
# %zmsaslogcheck(logfile=&_project.\programs\prog\&pgmname._log.log,
#                outfile=&_project.\programs\prog\&pgmname._logchk.lst);
# ----------------------------------------------------------------
#
# The SAS macro scans a program's LOG file after it runs, looking for
# ERROR/WARNING strings as a post-hoc quality check. R has no
# equivalent "log file" concept for a data step, but the same QC
# intent - catch structural problems before a dataset is used
# downstream - maps onto explicit, testable assertions about the data
# itself (the kind of thing packages like `assertr` or `pointblank`
# formalize; this uses base R so the example needs no extra
# packages).

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ae <- simulate_ae()

# 2. R (tidyverse) equivalent ----------------------------------------
# A small validation function that checks a set of expectations and
# reports every failure at once, instead of stopping at the first one
# - similar in spirit to a log-check report listing every issue found.
validate_ae <- function(dat) {
  checks <- list(
    "USUBJID has no missing values" = all(!is.na(dat$USUBJID)),
    "AESEQ is unique within USUBJID" = dat |>
      count(USUBJID, AESEQ) |>
      pull(n) |>
      (\(n) all(n == 1))(),
    "AESTDTC is a valid ISO 8601 date" = all(!is.na(as.Date(dat$AESTDTC, format = "%Y-%m-%d")))
  )

  failed <- names(checks)[!unlist(checks)]
  if (length(failed) > 0) {
    warning("Validation failed:\n", paste(" -", failed, collapse = "\n"))
  } else {
    message("All checks passed.")
  }

  invisible(checks)
}

# 3. Inspect output --------------------------------------------------
validate_ae(ae)
