# ============================================================
# Scenario: Link Cross-Domain Records via SDTM RELREC
# ============================================================
#
# --- Original SAS logic --------------------------------------
# data relrec_AECE;
#   set sdtm.relrec(where=(RDOMAIN in ("CE","AE")));
#   proc sort; by usubjid RELID;
# run;
# proc transpose data=relrec_AECE out=relrec_AECE_t
#     (where=(cmiss(CESEQ,AESEQ)=0));
#   by usubjid RELID;
#   var IDVARVAL;
#   id IDVAR;
# run;
# ----------------------------------------------------------------

library(dplyr)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# RELREC is SDTM's generic "these records are related" table: each
# linked pair shares a RELID, and one row per domain records which
# sequence number (IDVARVAL) that domain's half of the pair points to.
relrec <- tibble::tibble(
  USUBJID = c("STUDY-004", "STUDY-004", "STUDY-005", "STUDY-005"),
  RELID = c("1", "1", "1", "1"),
  RDOMAIN = c("CE", "AE", "CE", "AE"),
  IDVAR = c("CESEQ", "AESEQ", "CESEQ", "AESEQ"),
  IDVARVAL = c("1", "1", "1", "1")
)
ce <- tibble::tibble(
  USUBJID = c("STUDY-004", "STUDY-005"),
  CESEQ = c("1", "1"),
  CETERM = c("PROGRESSIVE DISEASE", "PROGRESSIVE DISEASE")
)
ae <- simulate_ae() |> mutate(AESEQ = as.character(AESEQ))

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS reshapes RELREC from long (one row per domain per pair) to wide
# (one row per pair, IDVAR values as columns) with PROC TRANSPOSE, then
# uses the wide CESEQ/AESEQ columns to pull in AETERM from AE. The same
# reshape is pivot_wider(); the SAS `cmiss(...)=0` filter (keep only
# fully-matched pairs) is just dropping NA rows after the pivot.
relrec_wide <- relrec |>
  select(USUBJID, RELID, IDVAR, IDVARVAL) |>
  pivot_wider(names_from = IDVAR, values_from = IDVARVAL) |>
  drop_na(CESEQ, AESEQ)

result <- relrec_wide |>
  left_join(ce, by = c("USUBJID", "CESEQ")) |>
  left_join(ae |> select(USUBJID, AESEQ, AETERM), by = c("USUBJID", "AESEQ"))

# 3. Inspect output --------------------------------------------------
result
