# ============================================================
# Scenario: Expand Multi-Select (Checkbox) Fields into Records
# ============================================================
#
# Purpose: A CRF checkbox field stores multiple selections in one row
# using numbered "slot" columns (MHLOC1..MHLOC9). This turns each
# non-missing slot into its own record so the dataset has one row per
# selected value, matching the one-value-per-row shape SDTM expects.
#
# --- Original SAS logic --------------------------------------
# if MHLOC="MULTIPLE" then do;
#   if ^missing(MHLOC1) then do; MHLOC=MHLOC1; output; end;
#   if ^missing(MHLOC2) then do; MHLOC=MHLOC2; output; end;
#   ...
#   if ^missing(MHLOC9) then do; MHLOC=MHLOC9; output; end;
# end;
# else output;
# ----------------------------------------------------------------

library(dplyr)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# A CRF checkbox field is captured as one row per subject with up to
# nine "slot" columns (MHLOC1..MHLOC9), most of them blank.
mh_wide <- tibble::tibble(
  USUBJID = usubjids[1:3],
  MHLOC = c("LIVER", "MULTIPLE", "LUNG"),
  MHLOC1 = c(NA, "LIVER", NA),
  MHLOC2 = c(NA, "BONE", NA),
  MHLOC3 = c(NA, "LYMPH NODE", NA)
)


# 2. R (tidyverse) equivalent ----------------------------------------
# SAS repeats the same "if slot is non-missing then output" block once
# per slot column. pivot_longer() does this in one call: it reshapes
# every MHLOCn column into (slot, value) pairs and drop_na() removes
# the blank slots, replacing the entire chain of manual OUTPUT
# statements.
multi_select <- mh_wide |>
  filter(MHLOC == "MULTIPLE") |>
  pivot_longer(cols = matches("^MHLOC[0-9]+$"), values_to = "MHLOC_EXPANDED") |>
  filter(!is.na(MHLOC_EXPANDED)) |>
  select(USUBJID, MHLOC = MHLOC_EXPANDED)

single_select <- mh_wide |>
  filter(MHLOC != "MULTIPLE") |>
  select(USUBJID, MHLOC)

result <- bind_rows(single_select, multi_select) |>
  arrange(USUBJID)

# 3. Inspect output --------------------------------------------------
result
