# ============================================================
# Scenario: Post-Baseline Max Value Flag + Directional Flags
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql noprint;
#   create table SR_posmax as select usubjid, paramcd, max(AVAL) as AVAL_posmax
#   from SR4(where=(...psblfl="Y")) group by usubjid, paramcd;
# quit;
# if psblfl="Y" and AVAL=AVAL_posmax and index(visit,"UNSCHEDULED")=0
#   then POSMAXFL="Y";
# if POSMAXFL="Y" and AVAL > base then GTBLFL="Y";
# if POSMAXFL="Y" and AVAL <= base then LEBLFL="Y";
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
lb <- simulate_lb() |>
  group_by(USUBJID) |>
  mutate(BASE = LBSTRESN[VISIT == "SCREENING"], PSBLFL = if_else(VISIT != "SCREENING", "Y", NA_character_)) |>
  ungroup()

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS finds each subject's post-baseline maximum with a PROC SQL
# subquery, then re-scans the data to flag the row that matches it and
# to flag whether it rose above or stayed at/below baseline. A single
# grouped mutate() computes the post-baseline max with max(), flags the
# matching row(s) with the equality check, and derives the directional
# flags from the same comparison to BASE - no separate join needed.
result <- lb |>
  filter(PSBLFL == "Y") |>
  group_by(USUBJID) |>
  mutate(
    AVAL_POSMAX = max(LBSTRESN),
    POSMAXFL = if_else(LBSTRESN == AVAL_POSMAX, "Y", "N"),
    GTBLFL = if_else(POSMAXFL == "Y" & LBSTRESN > BASE, "Y", NA_character_),
    LEBLFL = if_else(POSMAXFL == "Y" & LBSTRESN <= BASE, "Y", NA_character_)
  ) |>
  ungroup() |>
  select(USUBJID, VISIT, LBSTRESN, BASE, AVAL_POSMAX, POSMAXFL, GTBLFL, LEBLFL)

# 3. Inspect output --------------------------------------------------
result
