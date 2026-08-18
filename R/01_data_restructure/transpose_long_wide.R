# ============================================================
# Scenario: Transpose Long Data to Wide (SUPPxx Pattern)
# ============================================================
#
# Purpose: A SUPPxx table stores one qualifier per row (QNAM/QVAL).
# Downstream merges expect one row per subject/record with each
# qualifier as its own column, so this reshapes long to wide before
# joining SUPPxx data back onto its parent domain.
#
# --- Original SAS logic --------------------------------------
# proc transpose data=SUPPAE out=SUPPAE1;
#   by USUBJID AESEQ;
#   id QNAM;
#   var QVAL;
# run;
# ----------------------------------------------------------------

library(dplyr)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
suppae <- simulate_suppae()

# 2. R (tidyverse) equivalent ----------------------------------------
# SDTM "supplemental qualifier" tables store one qualifier per row
# (QNAM/QVAL). PROC TRANSPOSE with `id QNAM; var QVAL;` spreads that
# into one column per qualifier - the direct equivalent is
# tidyr::pivot_wider(), using QNAM for new column names and QVAL for
# their values.
result <- suppae |>
  pivot_wider(
    id_cols = c(STUDYID, USUBJID, AESEQ),
    names_from = QNAM,
    values_from = QVAL
  )

# 3. Inspect output --------------------------------------------------
glimpse(result)
