# ============================================================
# Scenario: Merge Two Datasets by Key
# ============================================================
#
# Purpose: Two datasets share a key (USUBJID/CMSEQ) but hold different
# columns. This combines them into one row per key, attaching the
# extra columns without duplicating or dropping any records.
#
# --- Original SAS logic --------------------------------------
# data CM2;
#   merge CM1 SUPPCM1;
#   by USUBJID CMSEQ;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
cm <- simulate_cm()
cm_extra <- cm |>
  distinct(USUBJID, CMSEQ) |>
  mutate(CMINDC = "PAIN")

# 2. R (tidyverse) equivalent ----------------------------------------
# A one-to-one SAS `merge ... by key` (both inputs pre-sorted by the
# same key) is a left_join() in dplyr: every row of the base dataset is
# kept, matching columns from the second dataset are attached by key,
# and no pre-sorting is required.
result <- cm |>
  left_join(cm_extra, by = c("USUBJID", "CMSEQ"))

# 3. Inspect output --------------------------------------------------
glimpse(result)
