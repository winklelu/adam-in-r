# ============================================================
# Scenario: Determine Treatment Period for an Event
# ============================================================
#
# --- Original SAS logic --------------------------------------
# if TR02SDT > input(substr(AESTDTC,1,10),yymmdd10.) then TRTGR1=TRT01A;
# else TRTGR1=TRT02A;
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# EX has two dosing rows per subject (period 1, period 2). Take the
# second period's start date as the period boundary.
period2_start <- simulate_ex() |>
  group_by(USUBJID) |>
  summarise(TR02SDT = ymd(max(EXSTDTC)), .groups = "drop")

ae <- simulate_ae() |> mutate(AESTDT = ymd(AESTDTC))

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS logic assigns an event to period 1 or period 2 purely by
# comparing the event date against the period-2 start date. Once the
# boundary date is joined on, if_else() reproduces the same either/or
# assignment.
result <- ae |>
  left_join(period2_start, by = "USUBJID") |>
  mutate(TRTPER = if_else(AESTDT < TR02SDT, "Period 1", "Period 2")) |>
  select(USUBJID, AETERM, AESTDT, TR02SDT, TRTPER)

# 3. Inspect output --------------------------------------------------
result
