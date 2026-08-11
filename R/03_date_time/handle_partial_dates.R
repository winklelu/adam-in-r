# ============================================================
# Scenario: Handle Partial (Incomplete) Dates
# ============================================================
#
# --- Original SAS logic --------------------------------------
# if length(AESTDTC)>10 and TRTSDT<=input(substr(AESTDTC,1,10),yymmdd10.)
#   then TRTEMFL="Y";
# else if length(AESTDTC)=7 and
#   substr(put(TRTSDT,yymmdd10.),1,4)<substr(AESTDTC,1,4)
#   then TRTEMFL="Y";
# ----------------------------------------------------------------

library(dplyr)
library(stringr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Source systems sometimes only capture a partial date (year-month or
# just year) when a subject can't recall the exact day. Build a small
# example set mixing full and partial ISO 8601 dates.
ae_partial <- tibble::tibble(
  USUBJID = c("STUDY-001", "STUDY-002", "STUDY-003"),
  AESTDTC = c("2024-01-15", "2024-03", "2024"),
  TRTSDT = ymd(c("2024-01-10", "2024-02-01", "2023-06-01"))
)

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS logic branches on the string length of the raw date-time
# character value (10 = full date, 7 = year-month, 4 = year only) and
# compares whatever precision is available. case_when() reproduces the
# same branching, using nchar() and substr()/str_sub() the same way
# the SAS code does.
result <- ae_partial |>
  mutate(
    TRTEMFL = case_when(
      nchar(AESTDTC) == 10 & TRTSDT <= ymd(AESTDTC) ~ "Y",
      nchar(AESTDTC) == 7 & year(TRTSDT) < as.integer(str_sub(AESTDTC, 1, 4)) ~ "Y",
      nchar(AESTDTC) == 4 & year(TRTSDT) < as.integer(AESTDTC) ~ "Y",
      TRUE ~ "N"
    )
  )

# 3. Inspect output --------------------------------------------------
result
