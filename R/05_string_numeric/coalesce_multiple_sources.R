# ============================================================
# Scenario: Coalesce Multiple Source Columns by Priority
# ============================================================
#
# Purpose: A result value can be captured in any of several source
# columns depending on how it was collected, in a fixed priority order.
# This picks the first non-missing value across those columns per row.
#
# --- Original SAS logic --------------------------------------
# case when ^missing(a.trstresn) then strip(put(a.trstresn,best.))
#      when missing(a.trstresn) then coalescec(a.TRSTRESC,a.AVAL_tu)
#      else "" end as AVALC
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# A result value can come from any of three source columns, in a fixed
# priority order: a numeric result first, then a character result,
# then a fallback derived elsewhere.
tr_results <- tibble::tibble(
  USUBJID = usubjids[1:4],
  TRSTRESN = c(32, NA, NA, NA),
  TRSTRESC = c(NA, "NOT DONE", NA, NA),
  AVAL_TU = c(NA, NA, "TARGET", NA)
)

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS CASE expression is a manual priority chain that also has to
# convert the numeric column to text before comparing it. coalesce()
# does exactly this in one call: return the first non-missing value
# across the listed columns, in the order given.
result <- tr_results |>
  mutate(AVALC = coalesce(as.character(TRSTRESN), TRSTRESC, AVAL_TU))

# 3. Inspect output --------------------------------------------------
result
