# ============================================================
# Scenario: Build PARAM / PARAMCD
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql;
# create table eg1 as
# select a.*,
#   case when a.EGTESTCD='EGHR' then 'HEART RATE'
#        when a.EGTESTCD='QTCF' then 'QTCF INTERVAL'
#        else '' end as PARAM length=40 label="Parameter"
# from eg as a;
# quit;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
eg <- simulate_eg()

# 2. R (tidyverse) equivalent ----------------------------------------
# ADaM PARAM/PARAMCD are typically built from a fixed lookup table
# tying each raw test code to its analysis parameter code and label.
# case_when() reproduces the SQL CASE expression directly, mapping
# each xxTESTCD to its PARAM/PARAMCD pair in one place.
result <- eg |>
  mutate(
    PARAMCD = EGTESTCD,
    PARAM = case_when(
      EGTESTCD == "EGHR" ~ "Heart Rate (beats/min)",
      EGTESTCD == "QTCF" ~ "QTcF Interval (msec)",
      TRUE ~ NA_character_
    )
  ) |>
  select(USUBJID, PARAMCD, PARAM, EGSTRESN)

# 3. Inspect output --------------------------------------------------
result
