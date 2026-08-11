# ============================================================
# Shared synthetic data generators
# ============================================================
#
# Purpose: every scenario script in this project sources this file to get
# small, fully synthetic, SDTM-like tibbles (no real subject data of any
# kind). Structures loosely mirror CDISC SDTM domains (DM, EX, AE, CM, VS,
# QS, SC, DS, LB, EG, PC, DV) and long-format "supplemental qualifier"
# tables (SUPPAE/SUPPCM/SUPPDM), which is what the original SAS ADaM
# programs read from.
#
# All generators are deterministic (fixed seed) so output is reproducible.

library(dplyr)
library(tibble)

set.seed(20260811)

n_subjects <- 8

usubjids <- sprintf("STUDY-%03d", 1:n_subjects)

# --- DM: Demographics ------------------------------------------------------
simulate_dm <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = usubjids,
    SUBJID = sprintf("%03d", 1:n_subjects),
    AGE = c(45, 62, 58, 71, 39, 66, 54, 49),
    SEX = rep(c("M", "F"), 4),
    ARMCD = rep(c("ARM A", "ARM B"), length.out = n_subjects),
    ARM = rep(c("Treatment A", "Treatment B"), length.out = n_subjects),
    RFXSTDTC = c(
      "2024-01-10", "2024-01-15", "2024-02-01", "2024-02-10",
      "2024-03-01", "2024-03-05", "2024-03-20", "2024-04-01"
    ),
    RFXENDTC = c(
      "2024-04-10", "2024-04-15", "2024-05-01", "2024-05-10",
      "2024-06-01", "2024-06-05", "2024-06-20", "2024-07-01"
    )
  )
}

# --- EX: Exposure ------------------------------------------------------------
simulate_ex <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, each = 2),
    EXSTDTC = rep(c("2024-01-10", "2024-02-10"), n_subjects),
    EXENDTC = rep(c("2024-01-24", "2024-02-24"), n_subjects),
    EXDOSE = rep(c(100, 150), n_subjects),
    EPOCH = rep(c("TREATMENT"), n_subjects * 2)
  )
}

# --- AE: Adverse events ------------------------------------------------------
simulate_ae <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, length.out = 12),
    AESEQ = c(2, 1, 1, 3, 1, 2, 1, 1, 2, 1, 1, 1),
    AETERM = c(
      "HEADACHE", "NAUSEA", "FATIGUE", "HEADACHE", "RASH", "NAUSEA",
      "DIZZINESS", "FATIGUE", "VOMITING", "RASH", "HEADACHE", "FATIGUE"
    ),
    AEDECOD = c(
      "Headache", "Nausea", "Fatigue", "Headache", "Rash", "Nausea",
      "Dizziness", "Fatigue", "Vomiting", "Rash", "Headache", "Fatigue"
    ),
    AESTDTC = c(
      "2024-01-15", "2024-01-12", "2024-02-05", "2024-02-20",
      "2024-02-15", "2024-02-18", "2024-03-10", "2024-03-08",
      "2024-03-25", "2024-03-22", "2024-04-05", "2024-04-10"
    ),
    AEENDTC = c(
      "2024-01-17", "2024-01-13", "2024-02-10", "2024-02-22",
      "2024-02-20", "2024-02-19", "2024-03-12", "2024-03-15",
      "2024-03-26", "2024-03-25", "2024-04-06", "2024-04-20"
    ),
    AEREL = c(
      "RELATED", "NOT RELATED", "POSSIBLY RELATED", "NOT RELATED",
      "PROBABLY RELATED", "NOT RELATED", "RELATED", "NOT RELATED",
      "NOT RELATED", "POSSIBLY RELATED", "NOT RELATED", "RELATED"
    )
  )
}

# --- CM: Concomitant medications -----------------------------------------------
simulate_cm <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, length.out = 6),
    CMSEQ = c(1, 1, 2, 1, 1, 1),
    CMTRT = c("PARACETAMOL", "IBUPROFEN", "ASPIRIN", "PARACETAMOL", "OMEPRAZOLE", "LORATADINE"),
    CMSTDTC = c("2024-01-16", "2024-01-13", "2024-02-06", "2024-02-21", "2024-03-11", "2024-04-06"),
    CMENDTC = c("2024-01-18", "2024-01-14", "2024-02-08", "2024-02-23", "2024-03-13", "2024-04-08")
  )
}

# --- VS: Vital signs ----------------------------------------------------------
simulate_vs <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, each = 2),
    VISIT = rep(c("SCREENING", "WEEK 4"), n_subjects),
    VSTESTCD = rep("WEIGHT", n_subjects * 2),
    VSSTRESN = round(rnorm(n_subjects * 2, mean = 70, sd = 10), 1)
  )
}

# --- QS: Questionnaire (e.g. ECOG) --------------------------------------------
simulate_qs <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = usubjids,
    VISIT = "SCREENING",
    QSTESTCD = "ECOG",
    QSSTRESN = sample(0:2, n_subjects, replace = TRUE)
  )
}

# --- SC: Subject characteristics -----------------------------------------------
simulate_sc <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = usubjids,
    SCTESTCD = "METSITE",
    SCORRES = sample(c("LIVER", "LUNG", "BONE", "NONE"), n_subjects, replace = TRUE)
  )
}

# --- DS: Disposition -----------------------------------------------------------
simulate_ds <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = usubjids,
    DSDECOD = c(
      "RANDOMIZED", "RANDOMIZED", "RANDOMIZED", "RANDOMIZED",
      "RANDOMIZED", "RANDOMIZED", "RANDOMIZED", "RANDOMIZED"
    ),
    DSTERM = c(
      "COMPLETED", "ADVERSE EVENT", "COMPLETED", "WITHDRAWAL BY SUBJECT",
      "COMPLETED", "COMPLETED", "PROGRESSIVE DISEASE", "COMPLETED"
    ),
    DSSTDTC = c(
      "2024-04-12", "2024-02-25", "2024-05-03", "2024-03-01",
      "2024-06-03", "2024-06-07", "2024-04-20", "2024-07-03"
    )
  )
}

# --- LB: Laboratory results ------------------------------------------------------
simulate_lb <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, each = 3),
    VISIT = rep(c("SCREENING", "WEEK 4", "WEEK 8"), n_subjects),
    LBTESTCD = "ALT",
    LBSTRESN = round(runif(n_subjects * 3, min = 10, max = 150), 1),
    LBSTNRHI = 40
  )
}

# --- EG: ECG ---------------------------------------------------------------------
simulate_eg <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, each = 2),
    EGTESTCD = rep(c("EGHR", "QTCF"), n_subjects),
    EGSTRESN = c(
      72, 410, 78, 420, 68, 405, 75, 430,
      70, 415, 80, 440, 74, 408, 76, 425
    )
  )
}

# --- PC: Pharmacokinetic concentrations -------------------------------------------
simulate_pc <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids, each = 3),
    PCTEST = "Drug X",
    PCTPT = rep(c("0 (PREDOSE)", "1H POST-DOSE", "4H POST-DOSE"), n_subjects),
    PCDTC = rep(c("2024-01-10T08:00", "2024-01-10T09:00", "2024-01-10T12:00"), n_subjects),
    ATPTREF = rep("2024-01-10T08:00", n_subjects * 3)
  )
}

# --- DV: Protocol deviations -----------------------------------------------------
simulate_dv <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = c("STUDY-004"),
    DVTERM = c("MISSED VISIT WINDOW")
  )
}

# --- SUPPAE: long-format qualifiers for AE (for transpose demos) -------------------
simulate_suppae <- function() {
  tibble(
    STUDYID = "STUDY",
    USUBJID = rep(usubjids[1:3], each = 2),
    AESEQ = rep(1, 6),
    QNAM = rep(c("AETOXGR", "AESER"), 3),
    QVAL = c("2", "N", "1", "N", "3", "Y")
  )
}
