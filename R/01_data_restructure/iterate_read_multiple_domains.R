# ============================================================
# Scenario: Iterate Over and Read Multiple Source Domains
# ============================================================
#
# Purpose: A study has many SDTM domains (DM, EX, AE, CM, ...) that all
# need to be pulled from a source library the same way. Rather than
# repeating the same read step once per domain, this loops over the
# list of domain names and applies one read step to each.
#
# --- Original SAS logic --------------------------------------
# proc copy in=sdtm out=work;
#   select dm ex ae cm vs qs sc pc dv;
# run;
# ----------------------------------------------------------------

library(dplyr)
library(purrr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# PROC COPY pulls a fixed list of named domains from one library into
# another in one step. The R equivalent is to hold the "which domain
# maps to which generator" relationship in a named list and iterate
# over it, rather than repeating a copy statement per domain.
domain_generators <- list(
  dm = simulate_dm,
  ex = simulate_ex,
  ae = simulate_ae,
  cm = simulate_cm,
  vs = simulate_vs,
  qs = simulate_qs,
  sc = simulate_sc,
  pc = simulate_pc,
  dv = simulate_dv
)

# 2. R (tidyverse) equivalent ----------------------------------------
# purrr::map() applies each generator function and returns a named list
# of tibbles - one call handles all domains instead of nine separate
# read statements.
domains <- map(domain_generators, \(generator) generator())

# 3. Inspect output --------------------------------------------------
map(domains, nrow)
