# ============================================================
# Scenario: Baseline Flag
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql;
# create table lb_base as
# select a.*,
#   case when a.visit='SCREENING' and ^missing(f.TRTSDT) then 'Y'
#   else '' end as ABLFL
# from lb as a left join dm as f
# on a.usubjid=f.usubjid;
# quit;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
lb <- simulate_lb()
dm <- simulate_dm()

# 2. R (tidyverse) equivalent ----------------------------------------
# ADaM baseline is typically "the last non-missing pre-treatment
# record" - here approximated as the SCREENING visit, since it is
# always collected before dosing. The SQL `case when ... end as ABLFL`
# pattern becomes a mutate() + if_else().
result <- lb |>
  left_join(dm |> select(USUBJID), by = "USUBJID") |>
  mutate(ABLFL = if_else(VISIT == "SCREENING", "Y", NA_character_))

# 3. Inspect output --------------------------------------------------
result
