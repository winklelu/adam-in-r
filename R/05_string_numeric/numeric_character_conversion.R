# ============================================================
# Scenario: Numeric / Character Conversion
# ============================================================
#
# --- Original SAS logic --------------------------------------
# AVAL=input(dastresc,best.);
# AVALC=compress(put(AVAL,best.));
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
qs <- tibble::tibble(
  USUBJID = c("STUDY-001", "STUDY-002", "STUDY-003"),
  QSORRES = c("1", "2", "NOT DONE")
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS's input()/put() pair converts character to numeric and back.
# as.numeric() is the direct equivalent of input(..., best.) - values
# that aren't valid numbers (like "NOT DONE") become NA with a
# warning, same as SAS setting AVAL to missing for a non-numeric
# character source value. as.character() mirrors put(..., best.).
result <- qs |>
  mutate(
    AVAL = suppressWarnings(as.numeric(QSORRES)),
    AVALC = as.character(AVAL)
  )

# 3. Inspect output --------------------------------------------------
result
