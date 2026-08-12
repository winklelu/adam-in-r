# ============================================================
# Scenario: Overall Response / Best Overall Response
# ============================================================
#
# --- Original SAS logic --------------------------------------
# select a.*, b.rsorres as rsorres_T1, ...,
#   case when a.RSTESTCD="OVRLRESP" and b.RSSTRESC="SD" and c.RSSTRESC="PD"
#          and b.PFSDY>=42 and a.RSSTRESC="SD" then 0
#        when ... then 1
#        else a.BestR_0 end as BestR_1
# from rstr as a
#   left join rstr as b on a.usubjid=b.usubjid and b.visit="WEEK 8 DAY 1"
# ----------------------------------------------------------------

library(dplyr)

source("R/00_data/simulate_data.R")

# 1. Prepare data --------------------------------------------------
rs <- simulate_rs()

# 2. R (tidyverse) equivalent ----------------------------------------
# The SAS logic self-joins the response table to a fixed confirmation
# visit so it can compare each response to what came next. This is a
# simplified version of that idea (a real RECIST BOR derivation also
# enforces a minimum confirmation interval): rank the response
# categories from best to worst, treat a response as "confirmed" if
# the following assessment isn't worse, and take each subject's best
# confirmed response with slice_min() after group_by(USUBJID) - the
# lead()-based lookahead replaces the self-join to "the next visit".
response_rank <- c(CR = 1, PR = 2, SD = 3, PD = 4, NE = 5)

result <- rs |>
  arrange(USUBJID, VISITNUM) |>
  group_by(USUBJID) |>
  mutate(
    RANK = response_rank[RSSTRESC],
    CONFIRMED = RANK <= lead(RANK, default = Inf)
  ) |>
  filter(CONFIRMED) |>
  slice_min(RANK, n = 1, with_ties = FALSE) |>
  ungroup() |>
  select(USUBJID, VISIT, BESTRESP = RSSTRESC)

# 3. Inspect output --------------------------------------------------
result
