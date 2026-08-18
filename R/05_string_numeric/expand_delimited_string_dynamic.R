# ============================================================
# Scenario: Expand a Delimited String into Multiple Records (Data-Driven)
# ============================================================
#
# Purpose: A free-text field holds a variable, unknown-in-advance
# number of comma-separated codes per subject. This splits each row's
# delimited string into one record per code, regardless of how many
# codes any given row has.
#
# --- Original SAS logic --------------------------------------
# proc sql noprint;
#   select max(count(scorres_new2,",")+1) into :m_num from sc_1;
# quit;
# data sc; set sc_1;
#   %macro mCMid;
#   %do i=1 %to &m_num;
#     CMID&i=scan(SCORRES_new2,&i,",");
#     if ^missing(CMID&i) then do; CMID=substr(CMID&i,4); output; end;
#   %end;
#   %mend;
#   %mcMid;
# run;
# ----------------------------------------------------------------

library(dplyr)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# One free-text field holds a variable number of comma-separated
# concomitant medication codes per subject.
sc <- tibble::tibble(
  USUBJID = usubjids[1:3],
  SCORRES_NEW2 = c("CM001,CM002", "CM010", "CM003,CM004,CM005")
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS has to first count the maximum number of comma-separated values
# across the whole dataset (`m_num`) so it knows how many times to run
# a %do loop of scan() calls. separate_rows() needs none of that setup
# - it splits every row's delimited string into as many rows as it
# takes, per row, in a single call.
result <- sc |>
  separate_rows(SCORRES_NEW2, sep = ",") |>
  mutate(CMID = substr(SCORRES_NEW2, 3, nchar(SCORRES_NEW2)))

# 3. Inspect output --------------------------------------------------
result
