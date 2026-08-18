# ============================================================
# Scenario: Derive Treatment Start/End Date from Exposure Records
# ============================================================
#
# Purpose: DM's reference dates (RFXSTDTC/RFXENDTC) aren't always
# trusted as-is. This derives treatment start/end directly from a
# subject's own dosing (EX) records - the earliest and latest exposure
# date - plus a count of dosing records.
#
# --- Original SAS logic --------------------------------------
# data EX_ST; set EX; by usubjid; if first.usubjid;
#   TRTSDT=EXSTDTC_date_num; run;
# data EX_EN; set EX; by usubjid; if last.usubjid;
#   TRTEDT=EXSTDTC_date_num; run;
# data EX_count; retain count 0; set EX; by usubjid;
#   if first.usubjid then count=1; else count+1; if last.usubjid; run;
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Rather than trusting DM.RFXSTDTC, TRTSDT/TRTEDT are derived here from
# the subject's own dosing records - the earliest and latest EX visit.
ex <- simulate_ex() |> mutate(EXSTDT = ymd(EXSTDTC))

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS needs three separate passes (first., last., and a retained
# counter) because it processes rows sequentially. A single grouped
# summarise() gets the min, max, and count of dosing records per
# subject in one pass.
result <- ex |>
  group_by(USUBJID) |>
  summarise(
    TRTSDT = min(EXSTDT),
    TRTEDT = max(EXSTDT),
    EX_COUNT = n(),
    .groups = "drop"
  )

# 3. Inspect output --------------------------------------------------
result
