# ============================================================
# Scenario: Toxicity Grade Derivation (CTCAE-like)
# ============================================================
#
# Purpose: Safety review grades abnormal lab values by severity, not
# just by "abnormal/normal". This derives a CTCAE-style toxicity grade
# by comparing a lab result against multiples of its upper limit of
# normal.
#
# --- Original SAS logic --------------------------------------
# if PARAMCD in ('ALT','AST') and AVAL~=. then do;
#   if 1*LBSTNRHI<AVAL<=3*LBSTNRHI then ATOXGR='1';
#   else if 3*LBSTNRHI < AVAL <= 5*LBSTNRHI then ATOXGR='2';
#   else if 5*LBSTNRHI < AVAL <= 20*LBSTNRHI then ATOXGR='3';
#   else if AVAL > 20*LBSTNRHI then ATOXGR='4';
# end;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
lb <- simulate_lb()

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS chained if/else-if evaluates a series of multiples of the
# upper limit of normal (LBSTNRHI) in order. case_when() evaluates its
# conditions top to bottom the same way and stops at the first match,
# so the ULN-multiple thresholds translate directly.
result <- lb |>
  filter(LBTESTCD == "ALT") |>
  mutate(
    ATOXGR = case_when(
      LBSTRESN > 20 * LBSTNRHI ~ "4",
      LBSTRESN > 5 * LBSTNRHI ~ "3",
      LBSTRESN > 3 * LBSTNRHI ~ "2",
      LBSTRESN > 1 * LBSTNRHI ~ "1",
      TRUE ~ "0"
    )
  ) |>
  select(USUBJID, VISIT, LBTESTCD, LBSTRESN, LBSTNRHI, ATOXGR)

# 3. Inspect output --------------------------------------------------
result
