# ============================================================
# Scenario: Set Variable Labels/Lengths in One Place (ATTRIB)
# ============================================================
#
# Purpose: ADaM deliverables need a documented label per variable, and
# that metadata should have one source of truth rather than being
# re-typed at every derivation step. This centralizes labels in one
# named list and attaches them to the output columns.
#
# --- Original SAS logic --------------------------------------
# %let adamattr=
# STUDYID length=$11 label='Study Identifier'
# USUBJID length=$200 label='Unique Subject Identifier'
# AGE length=8 label='Age'
# ;
# data adsl_f;
#   attrib &adamattr;
#   set adsl;
#   keep &adamkeepstring;
# run;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
dm <- simulate_dm()

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS ATTRIB centralizes label/length metadata for a whole set of
# variables applied to a dataset in one statement. R has no native
# per-column "label" concept, but the `labelled` (or base `attr()`)
# approach lets you attach the same kind of metadata to columns, kept
# in one named list for a single source of truth - mirroring the
# %let adamattr macro variable pattern.
var_labels <- c(
  STUDYID = "Study Identifier",
  USUBJID = "Unique Subject Identifier",
  AGE = "Age",
  SEX = "Sex"
)

result <- dm |>
  select(names(var_labels))

for (var in names(var_labels)) {
  attr(result[[var]], "label") <- var_labels[[var]]
}

# 3. Inspect output --------------------------------------------------
sapply(result, \(col) attr(col, "label"))
