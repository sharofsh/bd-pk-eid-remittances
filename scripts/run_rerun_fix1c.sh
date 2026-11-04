#!/bin/sh
# Remaining configurations after the container restart (cache reused).
set -e
Rscript scripts/04_forecast_run.R S1_w10 PK 2>&1 | grep -v "^Registered\|method \|as.zoo"
for cfg in S1_w30 S2_pre S3_uq; do
  for cc in BD PK; do Rscript scripts/04_forecast_run.R $cfg $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
done
Rscript scripts/05_evaluate.R 2>&1 | tail -1
echo ALL_DONE
