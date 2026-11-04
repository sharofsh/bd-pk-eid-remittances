#!/bin/sh
# Rerun after deviation 2026-11-04 (seasonal frequency in select_interventions). S5/S6 unaffected.
set -e
Rscript scripts/03_rq1_estimation.R 2>&1 | grep -v "^Registered\|method \|as.zoo"
for cfg in primary roll60 roll96 roll120 S4_airline S1_w10 S1_w30 S2_pre S3_uq; do
  for cc in BD PK; do Rscript scripts/04_forecast_run.R $cfg $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
done
Rscript scripts/04_forecast_run.R S9_pk_sep26 PK 2>&1 | grep -v "^Registered\|method \|as.zoo"
Rscript scripts/05_evaluate.R 2>&1 | tail -1
echo ALL_DONE
