# ============================================================
# Scenario: Inline Data Validation Warning (During Derivation)
# ============================================================
#
# --- Original SAS logic --------------------------------------
# data _NULL_;
#   set mhall;
#   if MHLOC="OTHER" and missing(MHLOCOTH) then
#     put "&_kinwar. there is missing other specify information"
#         usubjid= mhrefid=;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
mh_other <- tibble::tibble(
  USUBJID = usubjids[1:3],
  MHLOC = c("OTHER", "LIVER", "OTHER"),
  MHLOCOTH = c(NA, NA, "PANCREAS")
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS's DATA _NULL_ + put warning pattern flags suspicious rows in the
# middle of a program, without producing an output dataset. There is no
# tidyverse "print a warning and keep going" verb, so the same check is
# a small assertion helper: filter() finds the offending rows, and
# warning() reports them immediately, right where the check happens in
# the pipeline (rather than in a separate, centralized log-check pass).
check_missing_other_specify <- function(data) {
  bad_rows <- data |> filter(MHLOC == "OTHER" & is.na(MHLOCOTH))
  if (nrow(bad_rows) > 0) {
    warning(sprintf(
      "Missing 'other specify' text for: %s",
      paste(bad_rows$USUBJID, collapse = ", ")
    ))
  }
  data
}

result <- mh_other |>
  check_missing_other_specify()

# 3. Inspect output --------------------------------------------------
result
