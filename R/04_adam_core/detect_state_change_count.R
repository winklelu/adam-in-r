# ============================================================
# Scenario: Detect State-Change Count (LAG + RETAIN)
# ============================================================
#
# Purpose: A subject can have multiple dosing-interruption episodes,
# but each episode should be counted once, not once per interrupted
# interval within it. This counts distinct episodes by detecting when
# the interruption ID changes from the previous row.
#
# --- Original SAS logic --------------------------------------
# data adex_interruption_2;
#   set adex_interruption_1;
#   by usubjid ECTPT_w;
#   retain inputnum;
#   if ^missing(INTid) and lagINTid^=INTid then inputnum+1;
#   if first.usubjid then inputnum=0;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Each row is one dosing interval; INTID flags an interruption episode
# (non-missing when dosing was interrupted). A subject can be
# interrupted more than once, and each new episode should count once,
# not once per interrupted interval.
dose_status <- tibble::tibble(
  USUBJID = rep(usubjids[1:2], each = 5),
  ECTPT_W = rep(1:5, 2),
  INTID = c(NA, "A", "A", NA, "B", NA, NA, "A", "A", "A")
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS compares each row to the previous one with lag() + RETAIN,
# incrementing a counter whenever the interruption ID changes into a
# new non-missing value. dplyr's lag() does the same row-to-row
# comparison; cumsum() replaces the manual RETAIN accumulator.
result <- dose_status |>
  arrange(USUBJID, ECTPT_W) |>
  group_by(USUBJID) |>
  mutate(
    NEW_EPISODE = !is.na(INTID) & (is.na(lag(INTID)) | lag(INTID) != INTID),
    INTERRUPTION_COUNT = cumsum(NEW_EPISODE)
  ) |>
  ungroup()

# 3. Inspect output --------------------------------------------------
result
