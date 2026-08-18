# ============================================================
# Scenario: String Split / Concatenate
# ============================================================
#
# Purpose: A disposition term free-text field sometimes packs a main
# reason and a supplementary detail into one comma-separated string.
# This splits it into the main reason and (when present) the detail
# that follows.
#
# --- Original SAS logic --------------------------------------
# DCSREAS1=scan(DSTERM,1,",");
# if find(DSTERM,",")>0 then DCSREAP1=substr(DSTERM,find(DSTERM,",")+1);
# ----------------------------------------------------------------

library(dplyr)
library(stringr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
ds <- tibble::tibble(
  USUBJID = c("STUDY-002", "STUDY-004", "STUDY-007"),
  DSTERM = c(
    "ADVERSE EVENT, DRUG-RELATED RASH",
    "WITHDRAWAL BY SUBJECT",
    "PROGRESSIVE DISEASE, CONFIRMED BY SCAN"
  )
)

# 2. R (tidyverse) equivalent ----------------------------------------
# scan(x, 1, ",") pulls the text before the first comma; a manual
# find()/substr() combo pulls whatever comes after. stringr's
# str_split_fixed() does both in one call, splitting into a fixed
# number of columns without the separate "does a comma even exist"
# check SAS needs.
split_term <- str_split_fixed(ds$DSTERM, ",\\s*", n = 2)

result <- ds |>
  mutate(
    DCSREAS1 = split_term[, 1],
    DCSREAP1 = na_if(split_term[, 2], "")
  )

# 3. Inspect output --------------------------------------------------
result
