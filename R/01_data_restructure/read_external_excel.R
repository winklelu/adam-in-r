# ============================================================
# Scenario: Read an External Excel Data Source
# ============================================================
#
# Purpose: Vendor or central-reading data often arrives as an Excel
# workbook rather than a SAS/analysis dataset. This reads a specific
# named sheet into a tibble and drops rows missing the value needed
# downstream, instead of relying on a LIBNAME engine.
#
# --- Original SAS logic --------------------------------------
# options validvarname=V7;
# libname test xlsx "&_project.data\external data\..._Reviewer Result.xlsx";
# data Central;
#   set test.'Central Reading'n;
#   if ^missing(Final_Conclusion);
# run;
# ----------------------------------------------------------------

library(dplyr)
library(readxl)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# SAS points a LIBNAME engine at the workbook and treats each sheet as
# a dataset. There is no local workbook to read here, so a small one is
# written to a temp file first purely so the read step below is real.
central_reading <- tibble::tibble(
  USUBJID = usubjids[1:4],
  Final_Conclusion = c("CR", "PR", NA, "SD")
)
xlsx_path <- tempfile(fileext = ".xlsx")
writexl::write_xlsx(list(`Central Reading` = central_reading), xlsx_path)

# 2. R (tidyverse) equivalent ----------------------------------------
# readxl::read_excel() reads a named sheet directly into a tibble - no
# LIBNAME engine or ODS step required. filter() replaces the SAS
# `if ^missing(...)` row-subsetting statement.
result <- read_excel(xlsx_path, sheet = "Central Reading") |>
  filter(!is.na(Final_Conclusion))

# 3. Inspect output --------------------------------------------------
result
