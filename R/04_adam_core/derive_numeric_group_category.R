# ============================================================
# Scenario: Derive Numeric Grouping (Category Label + Numeric Code)
# ============================================================
#
# Purpose: Continuous baseline variables (age, lab values, disease
# burden) are often reported by category rather than raw value. This
# buckets a continuous value into a labeled group and its matching
# sort-order numeric code.
#
# --- Original SAS logic --------------------------------------
# if 0 < AAGE < 65 then do; AGEGR1="<65"; AGEGR1N=1; end;
# else if AAGE >=65 then do; AGEGR1=">=65"; AGEGR1N=2; end;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm()

# 2. R (tidyverse) equivalent ----------------------------------------
# This "continuous value -> label + numeric code" pattern recurs across
# several variables (age, lab measures, disease burden), each with a
# threshold-based if/else-if chain in SAS. case_when() reproduces the
# threshold logic directly, and the label/code pair is derived in the
# same mutate() call since AGEGR1N is just a lookup on AGEGR1.
result <- dm |>
  mutate(
    AGEGR1 = case_when(
      AGE < 65 ~ "<65",
      AGE >= 65 ~ ">=65"
    ),
    AGEGR1N = case_when(
      AGEGR1 == "<65" ~ 1,
      AGEGR1 == ">=65" ~ 2
    )
  ) |>
  select(USUBJID, AGE, AGEGR1, AGEGR1N)

# 3. Inspect output --------------------------------------------------
result
