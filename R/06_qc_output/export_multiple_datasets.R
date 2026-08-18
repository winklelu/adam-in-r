# ============================================================
# Scenario: Export/Iterate Output Across Multiple Datasets
# ============================================================
#
# Purpose: A study deliverable is several ADaM domains, each written to
# its own output file the same way. This exports every domain in a
# list to its own file in one call, instead of repeating an export
# step once per domain.
#
# --- Original SAS logic --------------------------------------
# %macro adamtoxpt(domain=);
#   libname xptout xport "&_project.\output\&domain..xpt";
#   proc copy in=adam out=xptout; select &domain; run;
# %mend;
# %adamtoxpt(domain=adsl);
# %adamtoxpt(domain=adae);
# ----------------------------------------------------------------

library(dplyr)
library(purrr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
datasets <- list(
  dm = simulate_dm(),
  ae = simulate_ae(),
  cm = simulate_cm()
)

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS macro is called once per domain to repeat the same export
# step. purrr::iwalk() applies a function to every element of a named
# list, using both the value (the dataset) and its name (the domain)
# to build each output path - one call replaces one macro call per
# domain.
out_dir <- file.path(tempdir(), "adam_export")
dir.create(out_dir, showWarnings = FALSE)

iwalk(datasets, \(dat, domain) {
  write.csv(dat, file.path(out_dir, paste0(domain, ".csv")), row.names = FALSE)
})

# 3. Inspect output --------------------------------------------------
list.files(out_dir)
