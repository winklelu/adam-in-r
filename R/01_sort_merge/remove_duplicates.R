# ============================================================
# Scenario: Remove Duplicate Records
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sort data=ae1 out=ae2 nodupkey;
#   by _all_;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ae <- simulate_ae()
ae_with_dupes <- bind_rows(ae, ae[1:2, ])

# 2. R (tidyverse) equivalent ----------------------------------------
# `proc sort ... nodupkey; by _all_;` sorts and drops rows that are
# complete duplicates across every variable. dplyr::distinct() does the
# same without requiring a prior sort.
result <- ae_with_dupes |>
  distinct()

# 3. Inspect output --------------------------------------------------
nrow(ae_with_dupes)
nrow(result)
