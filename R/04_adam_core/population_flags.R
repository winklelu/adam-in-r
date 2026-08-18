# ============================================================
# Scenario: Population Flags (Safety / Randomized / PK)
# ============================================================
#
# Purpose: Which analysis population a subject belongs to (safety,
# randomized, etc.) determines which tables/figures include them. This
# derives each population flag from its defining eligibility condition.
#
# --- Original SAS logic --------------------------------------
# if rfxstdtc^='' then SAFFL='Y'; else SAFFL='N';
# if ARMCD in ("ARM A","ARM B") then RANDFL='Y'; else RANDFL='N';
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm()

# 2. R (tidyverse) equivalent ----------------------------------------
# Each population flag is an independent condition-to-Y/N mapping, so
# a handful of if_else() calls inside one mutate() reproduces the
# sequence of SAS if/then/else blocks - one flag per line instead of
# one flag per statement block.
result <- dm |>
  mutate(
    SAFFL = if_else(!is.na(RFXSTDTC) & RFXSTDTC != "", "Y", "N"),
    RANDFL = if_else(ARMCD %in% c("ARM A", "ARM B"), "Y", "N")
  ) |>
  select(USUBJID, ARMCD, SAFFL, RANDFL)

# 3. Inspect output --------------------------------------------------
result
