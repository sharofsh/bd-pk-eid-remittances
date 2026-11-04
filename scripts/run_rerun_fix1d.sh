#!/bin/sh
set -e
Rscript scripts/04_forecast_run.R S2_pre PK 2>&1 | grep -v "^Registered\|method \|as.zoo"
for cc in BD PK; do Rscript scripts/04_forecast_run.R S3_uq $cc 2>&1 | grep -v "^Registered\|method \|as.zoo"; done
Rscript scripts/05_evaluate.R 2>&1 | tail -1
echo ALL_DONE
