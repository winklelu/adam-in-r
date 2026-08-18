# ============================================================
# Scenario: Derive a Composite Score (Sum of Components, All Required)
# ============================================================
#
# Purpose: A composite endpoint is only valid if every one of its
# components was measured - a partial sum would misrepresent severity.
# This sums the components per subject/visit and sets the composite to
# missing whenever any component is missing.
#
# --- Original SAS logic --------------------------------------
# if first.visitnum then do;
#   if ^missing(AVAL) then do; count=1; AVAL_sum=AVAL; end;
#   else AVAL_sum=0;
# end;
# else do;
#   if ^missing(AVAL) then do; count+1; AVAL_sum=AVAL_sum+AVAL; end;
# end;
# if last.visitnum;
# if count ^=6 then call missing(AVAL_sum);
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# A Local Skin Reaction composite score is the sum of six component
# scores at a visit; if any component is missing, the composite is not
# calculable and must be set to missing rather than partially summed.
n_components <- 6
lsr_components <- tibble::tibble(
  USUBJID = rep(usubjids[1:2], each = n_components),
  VISITNUM = rep(1, n_components * 2),
  COMPONENT = rep(paste0("LSR", 1:n_components), 2),
  AVAL = c(1, 2, 1, 0, 2, 1, 1, 2, NA, 0, 1, 1)
)

# 2. R (tidyverse) equivalent ----------------------------------------
# SAS tracks a running sum and a running count of non-missing
# components across rows with RETAIN, then blanks the total after the
# fact if the count never reached six. group_by() + summarise() gets
# the same sum and count directly, and the "all components required"
# rule becomes a simple if_else() on that count.
result <- lsr_components |>
  group_by(USUBJID, VISITNUM) |>
  summarise(
    N_COMPONENTS = sum(!is.na(AVAL)),
    AVAL_SUM = if_else(N_COMPONENTS == n_components, sum(AVAL, na.rm = TRUE), NA_real_),
    .groups = "drop"
  )

# 3. Inspect output --------------------------------------------------
result
