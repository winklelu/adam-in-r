# ============================================================
# Scenario: SQL-Style Join with Grouped Subquery
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql;
# create table tr01st as
# select studyid, usubjid, input(exstdtc,is8601dt.) as TR01SDTM
# from ex
# where EPOCH='TREATMENT'
# group by studyid, usubjid
# having exstdtc=min(exstdtc)
# ;
# quit;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ex <- simulate_ex()

# 2. R (tidyverse) equivalent ----------------------------------------
# PROC SQL's "group by ... having col = min(col)" pattern (find the
# first record per subject) maps to dplyr's group_by() + filter(),
# which keeps only the row(s) matching the per-group minimum.
result <- ex |>
  filter(EPOCH == "TREATMENT") |>
  group_by(STUDYID, USUBJID) |>
  filter(EXSTDTC == min(EXSTDTC)) |>
  ungroup() |>
  select(STUDYID, USUBJID, TR01SDTC = EXSTDTC)

# 3. Inspect output --------------------------------------------------
glimpse(result)
