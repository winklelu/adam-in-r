# ============================================================
# Scenario: Change from Baseline
# ============================================================
#
# Purpose: A core efficacy/safety metric is how much a value moved from
# its baseline. This carries each subject's baseline value onto every
# one of their records, then derives the change from baseline at each
# post-baseline visit.
#
# --- Original SAS logic --------------------------------------
# if ABLFL='Y' then BASE=AVAL;
# ...
# if ABLFL^='Y' and AVAL~=. and BASE~=. then CHG=AVAL-BASE;
# ----------------------------------------------------------------

library(dplyr)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
lb <- simulate_lb() |>
  mutate(ABLFL = if_else(VISIT == "SCREENING", "Y", NA_character_))

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS typically derives BASE with a separate pass that carries the
# ABLFL='Y' record's AVAL forward within each BY group (e.g. via
# RETAIN, or a self-merge back onto the baseline-only subset). In
# dplyr, group_by() + mutate() applies a group-wide summary
# (the baseline value) to every row within the group in one step,
# which is often cleaner than SAS's two-pass approach.
result <- lb |>
  group_by(USUBJID) |>
  mutate(
    BASE = LBSTRESN[ABLFL == "Y"][1],
    CHG = if_else(is.na(ABLFL), LBSTRESN - BASE, NA_real_)
  ) |>
  ungroup()

# 3. Inspect output --------------------------------------------------
result
