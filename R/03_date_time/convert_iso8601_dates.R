# ============================================================
# Scenario: Convert ISO 8601 Strings to Dates
# ============================================================
#
# Purpose: SDTM date/time variables are stored as ISO 8601 character
# strings, but ADaM derivations (study day, duration, comparisons)
# need real Date/datetime objects. This parses the character values
# into proper dates.
#
# --- Original SAS logic --------------------------------------
# if rfxstdtc^="" then TRTSDT=input(scan(rfxstdtc,1,'T'),yymmdd10.);
# if rfxstdtc^="" then TRTSDTM=input(rfxstdtc,is8601dt.);
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm()

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS reads the date portion with `input(scan(x,1,'T'), yymmdd10.)` and
# the full datetime with `input(x, is8601dt.)`. lubridate's ymd() and
# ymd_hms()/as_datetime() parse ISO 8601 strings directly, with no need
# to manually split on "T" first.
result <- dm |>
  mutate(
    TRTSDT = ymd(RFXSTDTC),
    TRTEDT = ymd(RFXENDTC)
  ) |>
  select(USUBJID, RFXSTDTC, TRTSDT, RFXENDTC, TRTEDT)

# 3. Inspect output --------------------------------------------------
glimpse(result)
