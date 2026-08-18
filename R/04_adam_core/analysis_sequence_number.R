# ============================================================
# Scenario: Analysis Sequence Number
# ============================================================
#
# Purpose: ADaM records need a per-subject sequence number (ASEQ) that
# uniquely orders each subject's records, e.g. by event date. This
# derives that running 1, 2, 3, ... counter within each subject.
#
# --- Original SAS logic --------------------------------------
# data ecog2; set ecog1;
#   by STUDYID USUBJID ECOGDTC VISITNUM;
#   if first.USUBJID and first.ECOGDTC and first.visitnum then ASEQ=1;
#   else ASEQ+1;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ae <- simulate_ae()

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS reconstructs a per-subject running counter with `first.<var>` +
# RETAIN because it processes rows sequentially. dplyr does the same
# thing declaratively: group_by(USUBJID) scopes the counter to each
# subject, and row_number() (after arranging into the desired order)
# produces 1, 2, 3, ... within each group.
result <- ae |>
  arrange(USUBJID, AESTDTC) |>
  group_by(USUBJID) |>
  mutate(ASEQ = row_number()) |>
  ungroup() |>
  select(USUBJID, AESTDTC, AETERM, ASEQ)

# 3. Inspect output --------------------------------------------------
result
