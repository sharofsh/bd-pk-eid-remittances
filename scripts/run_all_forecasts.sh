#!/bin/sh
# Runs every forecast configuration once (Phase 3). Order = priority.
set -e
for cfg in primary roll60 roll96 roll120 S4_airline S5_none S1_w10 S1_w30 S2_pre S3_uq S6_auto; do
  for cc in BD PK; do Rscript scripts/04_forecast_run.R $cfg $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
done
Rscript scripts/04_forecast_run.R S9_pk_sep26 PK 2>&1 | grep -v "^Registered\|method \|as.zoo"
echo ALL_DONE
