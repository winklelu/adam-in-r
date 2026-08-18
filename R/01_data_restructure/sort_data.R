# ============================================================
# Scenario: Sort a Dataset by Key Variables
# ============================================================
#
# Purpose: Downstream steps (by-group processing, first/last-record
# logic) depend on rows being in a specific key order. This puts the
# dataset into that order before anything else runs.
#
# --- Original SAS logic --------------------------------------
# proc sort data=SUPPAE; by USUBJID AESEQ; run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ae <- simulate_ae()

# 2. R (tidyverse) equivalent ----------------------------------------
# PROC SORT reorders rows in place by one or more key variables.
# dplyr::arrange() is the direct equivalent - it returns a new,
# row-ordered tibble instead of mutating in place.
result <- ae |>
  arrange(USUBJID, AESEQ)

# 3. Inspect output --------------------------------------------------
glimpse(result)
