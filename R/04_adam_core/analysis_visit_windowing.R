# ============================================================
# Scenario: Analysis Visit Windowing
# ============================================================
#
# --- Original SAS logic --------------------------------------
# proc sql;
# create table lb2 as
# select a.*, b.avisit, b.avisitn
# from lb1 as a left join sv as b
# on a.usubjid=b.usubjid and a.visit=b.visit;
# quit;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
lb <- simulate_lb()

# A visit-window lookup, analogous to what the SV (Subject Visits)
# domain provides: the standardized analysis visit and its numeric
# order for each raw collected VISIT value.
visit_lookup <- tibble::tibble(
  VISIT = c("SCREENING", "WEEK 4", "WEEK 8"),
  AVISIT = c("Baseline", "Week 4", "Week 8"),
  AVISITN = c(0, 4, 8)
)

# 2. R (tidyverse) equivalent ----------------------------------------
# The SQL left join against SV to attach standardized AVISIT/AVISITN
# is again a left_join() - here matching on VISIT, the raw collected
# visit name, to bring in its analysis-visit mapping.
result <- lb |>
  left_join(visit_lookup, by = "VISIT")

# 3. Inspect output --------------------------------------------------
result
