# ============================================================
# Scenario: Calculate Datetime Differences (PK Relative Time)
# ============================================================
#
# Purpose: PK sample timing is analyzed relative to a reference time
# point (e.g. dose time), not as an absolute clock time. This derives
# the elapsed hours between a sample's collection datetime and its
# reference datetime.
#
# --- Original SAS logic --------------------------------------
# if PCDTC_~=. and ATPTREF_~=. then
#   ARELTM=round(((PCDTC_-ATPTREF_)/3600),0.01);
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
pc <- simulate_pc()

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS datetimes are stored as seconds since 1960-01-01, so dividing a
# difference by 3600 converts seconds to hours. In R, subtracting two
# POSIXct values returns a `difftime`; specifying `units = "hours"`
# does the same conversion without a manual divisor.
result <- pc |>
  mutate(
    PCDTM = ymd_hm(PCDTC),
    ATPTREFDTM = ymd_hm(ATPTREF),
    ARELTM = round(as.numeric(difftime(PCDTM, ATPTREFDTM, units = "hours")), 2)
  ) |>
  select(USUBJID, PCTPT, PCDTM, ATPTREFDTM, ARELTM)

# 3. Inspect output --------------------------------------------------
result
