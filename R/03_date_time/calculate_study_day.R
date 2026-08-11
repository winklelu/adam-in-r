# ============================================================
# Scenario: Calculate Relative Study Day
# ============================================================
#
# --- Original SAS logic --------------------------------------
# if eosdt>. and trtsdt>. then EOSDY=EOSDT-TRTSDT+1;
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm() |>
  mutate(
    TRTSDT = ymd(RFXSTDTC),
    EOSDT = ymd(RFXENDTC)
  )

# 2. R (tidyverse) equivalent ----------------------------------------
# CDISC study day is 1-based and skips day 0 (there is no "day zero" -
# the treatment start date is day 1), which is why SAS adds 1 after
# subtracting. The same +1 offset applies when subtracting Date
# objects in R.
result <- dm |>
  mutate(EOSDY = as.integer(EOSDT - TRTSDT) + 1) |>
  select(USUBJID, TRTSDT, EOSDT, EOSDY)

# 3. Inspect output --------------------------------------------------
result
