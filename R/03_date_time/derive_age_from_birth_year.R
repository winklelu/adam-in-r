# ============================================================
# Scenario: Derive Age from Birth Year Only (No Full Birth Date)
# ============================================================
#
# Purpose: Some source systems capture only a subject's birth year, not
# a full birth date, so age can't always be computed the same way. This
# derives age from a placeholder date when only the year is known, and
# falls back to the pre-derived AGE value when neither is usable.
#
# --- Original SAS logic --------------------------------------
# if cmiss(RFICDT, BRTHYEAR) > 0 then AAGE=AGE;
# else AAGE=INT((RFICDT - input(compress(cat("01","JUL",BRTHYEAR)),date9.))/365.25);
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Some source systems only capture the subject's birth year, not a
# full birth date. AGE is the pre-computed fallback used whenever the
# consent date or birth year is missing.
dm_age <- tibble::tibble(
  USUBJID = usubjids[1:3],
  RFICDT = ymd(c("2024-01-05", "2024-02-10", NA)),
  BRTHYEAR = c(1975, NA, 1980),
  AGE = c(48, 55, 43)
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS fills in a placeholder day/month (01-JUL) so a full date can be
# subtracted when only the birth year is known, falling back to the
# pre-derived AGE otherwise. make_date() builds the same placeholder
# date directly from the year, and case_when() reproduces the
# missing-value fallback.
result <- dm_age |>
  mutate(
    AAGE = case_when(
      is.na(RFICDT) | is.na(BRTHYEAR) ~ AGE,
      TRUE ~ as.integer((RFICDT - make_date(BRTHYEAR, 7, 1)) / 365.25)
    )
  ) |>
  select(USUBJID, RFICDT, BRTHYEAR, AGE, AAGE)

# 3. Inspect output --------------------------------------------------
result
