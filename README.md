# Eid effects in monthly workers' remittances: Bangladesh and Pakistan

Working title: *Islamic-Calendar Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan*

Two questions:
1. Are Eid al-Fitr and Eid al-Adha associated with changes in monthly workers' remittances in Bangladesh and Pakistan, and do the effects differ between the countries?
2. Does including Eid regressors improve out-of-sample forecasts?

The pre-specified analysis plan is in [DESIGN.md](DESIGN.md) (v1.0, date-stamped 4 Nov 2026). The 3 Nov working draft is in `docs/`.

**Results of the confirmatory run (4 Nov 2026): [results/REPORT.md](results/REPORT.md).**

## Data

| File | Country | Period | Units | Source |
|---|---|---|---|---|
| `data/bd_remittances_monthly.csv` | Bangladesh | Jul 2009 to Jul 2026 | US$ million (`remittances_usd_mn`); Tk crore also given | Bangladesh Bank, *Monthly Economic Trends*, compiled across issues with vintage tracking (`n_vintages`, `source_issue`) |
| `data/pk_remittances_monthly.csv` | Pakistan | Jul 2005 to Sep 2026 | US$ million, original (`remittances_usd_mn`); SBP seasonally adjusted (`remittances_sa_usd_mn`) to Dec 2024 only | State Bank of Pakistan: to Dec 2024, *Workers' Remittances (Credit), Seasonally Adjusted* (file "SA workers' Remittances Nov24.xlsx", printed 9 Jan 2025); from Jan 2025, SBP bulletins and press figures (per-row `source`; see DATA.md §1a) |

| `data/eid_dates.csv` | both | Eid al-Fitr and Eid al-Adha, 1426–1447 AH | local national date, Umm al-Qura date, status, source | news reports of the national moon-sighting announcements; see DATA.md |
| `data/eid_exposure_monthly.csv` | both | each country's span | share of each Eid window in the month (21-day primary; 10/30-day, day-before, Umm al-Qura variants) | built by `scripts/01_eid_exposure.R` |

Data documentation, including the Eid-date verification, is in [DATA.md](DATA.md).

Notes:
- Use the original Pakistan series. The SBP seasonal adjustment method is not documented in the source file and may already remove Eid effects.
- Pakistan Jan 2025 – Sep 2026 were appended from SBP bulletins and press figures, because EasyData is not reachable from the analysis workspace (DATA.md §1a).
- Both series come from public central-bank publications. Check each source's terms of reuse before redistributing further.

## Layout

```
data/      input series, Eid dates and exposure regressors
scripts/   one script per analysis step
           00_build_eid_dates.py  (Python, needs hijri-converter)
           01_eid_exposure.R
           lib_outliers.R, lib_model.R   (shared code: Chen-Liu outlier detection, intervention rule, order selection)
           02_identify_sarima_benchmark.R
           03_rq1_estimation.R           (RQ1 and in-sample sensitivities)
           04_forecast_run.R <config> <country>   (rolling-origin forecasts)
           run_all_forecasts.sh          (all configs)
           05_evaluate.R                 (accuracy, Clark-West, Diebold-Mariano, windows, periods)
results/   tables and figures produced by the scripts; REPORT.md
```

## Reproducing (R 4.3+, packages forecast, sandwich, lmtest, strucchange, digest)

Run from the repo root (in RStudio: set the working directory to the repo first; on Windows run the 04 loop from R instead of the shell script):

```
Rscript scripts/02_identify_sarima_benchmark.R
Rscript scripts/03_rq1_estimation.R
sh scripts/run_all_forecasts.sh      # about 1.5 h on 2 cores; per-origin selections are cached in results/cache/
Rscript scripts/05_evaluate.R
```

On Windows, `mclapply` runs on one core: expect a few hours.
