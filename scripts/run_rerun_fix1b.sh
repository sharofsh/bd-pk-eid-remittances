#!/bin/sh
# Continuation of run_rerun_fix1.sh in priority order (primary already done).
set -e
Rscript scripts/04_forecast_run.R X_B5_LS BD 2>&1 | grep -v "^Registered\|method \|as.zoo"
Rscript scripts/04_forecast_run.R X_B5_AO_LS BD 2>&1 | grep -v "^Registered\|method \|as.zoo"
for cc in BD PK; do Rscript scripts/04_forecast_run.R S4_airline $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
Rscript scripts/04_forecast_run.R S9_pk_sep26 PK 2>&1 | grep -v "^Registered\|method \|as.zoo"
for cfg in roll60 roll96 roll120 S1_w10 S1_w30 S2_pre S3_uq; do
  for cc in BD PK; do Rscript scripts/04_forecast_run.R $cfg $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
done
Rscript scripts/05_evaluate.R 2>&1 | tail -1
echo ALL_DONE
