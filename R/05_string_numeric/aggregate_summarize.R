# ============================================================
# Scenario: Aggregate / Summarize (PROC SQL Aggregate Functions)
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql noprint;
# create table pc01 as
# select studyid, usubjid, PCTEST, count(usubjid) as PK_freq
# from pc
# group by studyid, usubjid, PCTEST
# order by studyid, usubjid, PCTEST
# ;
# quit;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
pc <- simulate_pc()

# 2. R (tidyverse) equivalent ----------------------------------------
# PROC SQL's `select ..., count(x) as ... group by ... order by ...`
# maps directly onto dplyr's group_by() + summarise() (for the
# aggregate) followed by arrange() (for the ordering).
result <- pc |>
  group_by(STUDYID, USUBJID, PCTEST) |>
  summarise(PK_freq = n(), .groups = "drop") |>
  arrange(STUDYID, USUBJID, PCTEST)

# 3. Inspect output --------------------------------------------------
result
