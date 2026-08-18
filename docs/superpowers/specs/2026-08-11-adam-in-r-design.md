# adam-in-r — Design Spec

Date: 2026-08-11
Status: Approved

## Purpose

A job-search portfolio / practice project that translates the functional
scenarios commonly found in SAS ADaM programming (sorting, merging, date
derivation, baseline flags, toxicity grading, etc.) into idiomatic R
(tidyverse) code. The primary long-term goal is to share this publicly
(e.g. as a standalone GitHub repo, optionally linked from
https://winklelu.github.io/WinSual/winviz.html later); demonstrating R
proficiency for job applications is a secondary, immediate use case.

Source material: functional scenarios extracted from the SAS ADaM programs
of protocol KX-ORAX-002, catalogued in
`/Users/winkle/__Projects/SAS_Research/SAS_ADaM/adam_functional_scenarios.md`.
That document is the living, Chinese-language reference note the author
keeps for themself; this repo is the English-language, public-facing
translation of a subset of those scenarios into R.

## Location & Repo

- Path: `/Users/winkle/__Projects/R/adam-in-r`
- Independent git repository (not nested inside `SAS_Research` or the
  `Winkode`/WinSual blog repo). Kept independent so it can be shared as a
  standalone link and, separately, optionally featured later as a card on
  `winviz.html` (which currently only links to tools living inside the
  WinSual repo's `tools/` folder — an external repo link works fine too).
- All content (comments, README, scenario descriptions) is in English.

## Style

- tidyverse-first (dplyr, tidyr, stringr, lubridate, purrr) rather than
  base R, matching common employer expectations for modern R work.
- No real subject-level data. A single shared synthetic-data module
  (`R/00_data/simulate_data.R`) generates small, fully fabricated,
  SDTM-shaped tibbles (DM, EX, AE, CM, VS, QS, SC, DS, LB, EG, PC, DV, and
  a long-format SUPPAE table for transpose demos). Fixed seed for
  reproducibility.

## Structure

```
adam-in-r/
├── README.md
├── _template.R
├── docs/superpowers/specs/2026-08-11-adam-in-r-design.md
└── R/
    ├── 00_data/simulate_data.R
    ├── 01_data_restructure/            (6 scenarios)
    ├── 02_variable_attrib/       (2 scenarios)
    ├── 03_date_time/             (4 scenarios)
    ├── 04_adam_core/             (9 scenarios)
    ├── 05_string_numeric/        (3 scenarios)
    └── 06_qc_output/             (2 scenarios)
```

One R file per functional scenario (26 total), grouped into subfolders
that mirror the six sections of the source SAS scenario document. Each
file is self-contained and runnable on its own
(`Rscript R/<folder>/<file>.R` from the project root).

### Scenario list (SAS concept → R file)

**01_data_restructure**
1. Sort a dataset by key variables → `sort_data.R`
2. Merge two datasets by key → `merge_datasets.R`
3. SQL-style join / subquery with aggregation → `sql_join_subquery.R`
4. Long → wide transpose → `transpose_long_wide.R`
5. Iterate over and read multiple source domains (PROC COPY equivalent) →
   `iterate_read_multiple_domains.R`
6. Remove duplicate records → `remove_duplicates.R`

**02_variable_attrib**
1. Set variable labels/lengths in one place (ATTRIB) →
   `set_variable_attributes.R`
2. Control output column order (RETAIN) → `control_variable_order.R`

**03_date_time**
1. Convert ISO 8601 strings to dates → `convert_iso8601_dates.R`
2. Handle partial (incomplete) dates → `handle_partial_dates.R`
3. Calculate relative study day → `calculate_study_day.R`
4. Calculate datetime differences (PK relative time) →
   `calculate_datetime_difference.R`

**04_adam_core** (core ADaM derivation idioms)
1. Treatment-emergent flag → `treatment_emergent_flag.R`
2. Baseline flag → `baseline_flag.R`
3. Change from baseline → `change_from_baseline.R`
4. Build PARAM/PARAMCD → `build_param_paramcd.R`
5. Determine treatment period → `determine_treatment_period.R`
6. Toxicity grade derivation → `toxicity_grade.R`
7. Population flags (safety/randomized/PK) → `population_flags.R`
8. Analysis sequence number → `analysis_sequence_number.R`
9. Analysis visit windowing → `analysis_visit_windowing.R`

**05_string_numeric**
1. String split/concatenate → `string_split_concatenate.R`
2. Numeric ↔ character conversion → `numeric_character_conversion.R`
3. Aggregate/summarize (PROC SQL aggregate functions) →
   `aggregate_summarize.R`

**06_qc_output**
1. Export/iterate output across multiple datasets (macro-driven XPT
   export, reinterpreted) → `export_multiple_datasets.R`
2. Data validation checks (log-check macro, reinterpreted as assertion
   checks) → `data_validation_checks.R`

### Scenarios intentionally dropped from the original 27

Two items from the source SAS document are pure SAS project-management
conventions with no meaningful R translation as a skill demo, so they are
not written as separate files (noted in the README instead):
- Clearing the WORK library at the top of every program (`proc datasets
  ... kill`) — the R equivalent is simply a fresh session / `rm(list =
  ls())`, not worth a dedicated file.
- Log-redirection boilerplate (`proc printto`) — no R analog worth
  demonstrating.

## File template

Every scenario file follows `_template.R`:

```r
# ============================================================
# Scenario: <Short Scenario Title>
# ============================================================
#
# --- Original SAS logic --------------------------------------
# <original SAS snippet as a comment>
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# 2. R (tidyverse) equivalent ----------------------------------------
# 3. Inspect output --------------------------------------------------
```

The original SAS snippet and the R translation live in the same file, one
above the other, so a reader (e.g. an interviewer) can see both without
switching windows.

## Cross-referencing

`adam_functional_scenarios.md` (in `SAS_Research/SAS_ADaM`) gets an "R
File" reference added to each scenario entry that has a corresponding file
in this repo, so future updates to either document can be kept in sync.

## Out of scope for this iteration

- Publishing to GitHub / making the repo public.
- Adding a card to `winviz.html`.
- Package-ifying the repo (e.g. `devtools`/`usethis` scaffolding),
  `renv` lockfile, or CI.
- Base R equivalents (tidyverse-only, per author's explicit choice).
