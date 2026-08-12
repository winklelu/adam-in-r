# ============================================================
# Scenario: Extract/Match Text with a Regular Expression
# ============================================================
#
# --- Original SAS logic --------------------------------------
# if prxmatch('/(\/\d+\/)/',CMDECOD) then
#   ACMDECOD = strip(substr(CMDECOD,1,prxmatch('/(\/\d+\/)/',CMDECOD)-1));
# ...
# if ^prxmatch("/<|>=|>|<=|-/",LBORRES) and ^anyalpha(LBORRES)
#   and index(LBORRES,"+")=0 then AVAL=input(LBORRES,best.);
# ----------------------------------------------------------------

library(dplyr)
library(stringr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# Coded medication terms sometimes carry a trailing "/123/"-style code
# that needs stripping before the term is usable as a label; lab
# results sometimes carry qualifiers (">10", "<5") that make the value
# non-numeric and should be excluded from a straight numeric AVAL.
cm_decod <- tibble::tibble(CMDECOD = c("PARACETAMOL/001/", "IBUPROFEN", "ASPIRIN/042/"))
lb_orres <- tibble::tibble(LBORRES = c("42.5", ">100", "<0.5", "38"))

# 2. R (tidyverse) equivalent ----------------------------------------
# prxmatch() locates a PCRE pattern and returns its position; SAS then
# has to call it a second time inside substr() to reuse that position.
# stringr's str_remove() with the same pattern strips the match in one
# pass. The second SAS check (exclude qualifier-prefixed results from
# numeric conversion) is a single str_detect() guard inside case_when().
result_cm <- cm_decod |>
  mutate(ACMDECOD = str_remove(CMDECOD, "/\\d+/$"))

result_lb <- lb_orres |>
  mutate(
    AVAL = case_when(
      str_detect(LBORRES, "[<>]") ~ NA_real_,
      TRUE ~ as.numeric(LBORRES)
    )
  )

# 3. Inspect output --------------------------------------------------
result_cm
result_lb
