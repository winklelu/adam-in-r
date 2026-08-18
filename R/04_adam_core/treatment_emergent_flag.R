# ============================================================
# Scenario: Treatment-Emergent Flag
# ============================================================
#
# --- Original SAS logic --------------------------------------
# if AESTDTC >= TRTSDT then TRTEMFL="Y";
# else TRTEMFL="N";
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm() |> mutate(TRTSDT = ymd(RFXSTDTC))
ae <- simulate_ae() |> mutate(AESTDT = ymd(AESTDTC))

# 2. R (tidyverse) equivalent ----------------------------------------
# The treatment-emergent flag needs the subject's treatment start date
# alongside every AE record, so this first requires the same kind of
# by-key join covered in 01_data_restructure/merge_datasets.R, then a
# straightforward date comparison with if_else().
result <- ae |>
  left_join(dm |> select(USUBJID, TRTSDT), by = "USUBJID") |>
  mutate(TRTEMFL = if_else(AESTDT >= TRTSDT, "Y", "N")) |>
  select(USUBJID, AETERM, AESTDT, TRTSDT, TRTEMFL)

# 3. Inspect output --------------------------------------------------
result
