# ============================================================
# Scenario: Time-to-Event (PFS/OS) Date + Censoring Derivation
# ============================================================
#
# --- Original SAS logic --------------------------------------
# case when a.paramcd="PFS" and nmiss(b.trdt,a.dthdt,d.cmstdt)<3
#        then min(b.trdt,a.dthdt,d.cmstdt)
#      when a.paramcd="PFS" and nmiss(...)=3 then c.trdt_tulast
#      when a.paramcd="OS" and dthfl="Y" then a.dthdt
#      when a.paramcd="OS" and dthfl^="Y" then e.lastdate_n
#      else . end as ADT,
# ... EVNTDESC (which date won) and CNSR (0=event, 1=censored)
# ----------------------------------------------------------------

library(dplyr)
library(lubridate)
library(tidyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
# PFS needs the earliest of several candidate event dates (progression,
# death, new anti-cancer therapy); OS needs the death date if the
# subject died, otherwise the last date known alive. Progression date
# comes from the response data; death/last-alive dates aren't tracked
# elsewhere in this project's synthetic domains, so a small outcome
# table stands in for them here.
rs <- simulate_rs()
pd_date <- rs |>
  filter(RSSTRESC == "PD") |>
  group_by(USUBJID) |>
  summarise(PDDT = min(ymd(RSDTC)), .groups = "drop")

outcome <- tibble::tibble(
  USUBJID = usubjids[1:4],
  DTHDT = ymd(c(NA, "2024-07-15", NA, "2024-08-01")),
  LSTALVDT = ymd(c("2024-06-15", "2024-07-15", "2024-06-20", "2024-08-01"))
)

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS CASE expression picks the earliest of several candidate
# dates with min(), falls back to a "last known" date when no event
# date exists at all, and derives EVNTDESC/CNSR from which candidate
# won. pmin(..., na.rm = TRUE) does the multi-column earliest-date
# comparison directly; case_when() reproduces the fallback and the
# "0 = event, 1 = censored" CNSR coding from the same comparison.
subj <- outcome |>
  left_join(pd_date, by = "USUBJID")

pfs <- subj |>
  mutate(
    PARAMCD = "PFS",
    ADT = pmin(PDDT, DTHDT, na.rm = TRUE),
    ADT = coalesce(ADT, LSTALVDT),
    EVNTDESC = case_when(
      !is.na(DTHDT) & ADT == DTHDT ~ "DEATH",
      !is.na(PDDT) & ADT == PDDT ~ "PROGRESSION DISEASE",
      TRUE ~ "LAST ADEQUATE ASSESSMENT"
    ),
    CNSR = if_else(EVNTDESC %in% c("DEATH", "PROGRESSION DISEASE"), 0, 1)
  )

os <- subj |>
  mutate(
    PARAMCD = "OS",
    ADT = coalesce(DTHDT, LSTALVDT),
    EVNTDESC = if_else(!is.na(DTHDT), "DEATH", "LAST KNOWN ALIVE"),
    CNSR = if_else(!is.na(DTHDT), 0, 1)
  )

result <- bind_rows(pfs, os) |>
  select(USUBJID, PARAMCD, ADT, EVNTDESC, CNSR)

# 3. Inspect output --------------------------------------------------
result
