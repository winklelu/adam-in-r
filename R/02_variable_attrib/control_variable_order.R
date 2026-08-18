# ============================================================
# Scenario: Control Output Variable Order (RETAIN)
# ============================================================
#
# Purpose: A dataset's columns can end up in an arbitrary order after
# merges/derivations, but ADaM output needs key identifier columns
# first. This reorders columns to a specified layout without changing
# any values.
#
# --- Original SAS logic --------------------------------------
# data ae;
#   retain STUDYID USUBJID AESEQ AETERM AEDECOD AESTDTC AEENDTC;
#   set ae2;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ae <- simulate_ae()

# 2. R (tidyverse) equivalent ----------------------------------------
# Using RETAIN purely to fix column order (rather than to carry a
# value across rows) has a direct dplyr equivalent: relocate() moves
# named columns to the front (or to a specified position), regardless
# of what order they were created/merged in.
result <- ae |>
  relocate(STUDYID, USUBJID, AESEQ, AETERM, AEDECOD, AESTDTC, AEENDTC)

# 3. Inspect output --------------------------------------------------
names(result)
