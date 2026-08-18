# ============================================================
# Scenario: RECIST Lesion Classification -> PARAM/PARAMCD
# ============================================================
#
# Purpose: Tumor lesion records are categorized (target/non-target/new
# lesion) and tested in different ways (site, diameter, status), and
# each combination reports under its own PARAM/PARAMCD. This maps each
# lesion-category-and-test combination to its analysis parameter.
#
# --- Original SAS logic --------------------------------------
# if grpid="TARGET" and tutestcd="TUMIDENT" then do;
#   paramcd="TSITE"; param="Site of Target Lesion";
# end;
# else if grpid="NON-TARGET" and tutestcd="TUMIDENT" then do;
#   paramcd="NTSITE"; param="Site of Non-Target Lesion";
# end;
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Tumor lesion records (SDTM TU/TR) carry a lesion category (GRPID:
# TARGET/NON-TARGET/NEW LESION) and a test code (identification vs.
# diameter measurement vs. status). This is the same "combination of
# codes -> PARAMCD/PARAM" idea as 04_adam_core/build_param_paramcd.R,
# applied to the oncology domain, where the combination space is
# larger and study-specific enough to be worth its own scenario.
tr <- simulate_tr()

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS if/else-if chain tests GRPID and TUTESTCD together for each
# branch. case_when() reproduces this directly with combined boolean
# conditions, evaluated top to bottom.
result <- tr |>
  mutate(
    PARAMCD = case_when(
      GRPID == "TARGET" & TUTESTCD == "TUMIDENT" ~ "TSITE",
      GRPID == "TARGET" & TUTESTCD == "LDIAM" ~ "TDIAM",
      GRPID == "NON-TARGET" & TUTESTCD == "TUMIDENT" ~ "NTSITE",
      GRPID == "NON-TARGET" & TUTESTCD == "TUMSTATE" ~ "NTSTAT",
      GRPID == "NEW LESION" ~ "NEWLSN"
    ),
    PARAM = case_when(
      PARAMCD == "TSITE" ~ "Site of Target Lesion",
      PARAMCD == "TDIAM" ~ "Diameter of Target Lesion (mm)",
      PARAMCD == "NTSITE" ~ "Site of Non-Target Lesion",
      PARAMCD == "NTSTAT" ~ "Status of Non-Target Lesion",
      PARAMCD == "NEWLSN" ~ "New Lesion Identified"
    )
  ) |>
  select(USUBJID, GRPID, TUTESTCD, TRLOC, PARAMCD, PARAM, TRSTRESN)

# 3. Inspect output --------------------------------------------------
result
