# Eid effects in monthly workers' remittances: Bangladesh and Pakistan

Working title: *Islamic-Calendar Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan*

Two questions:
1. Are Eid al-Fitr and Eid al-Adha associated with changes in monthly workers' remittances in Bangladesh and Pakistan, and do the effects differ between the countries?
2. Does including Eid regressors improve out-of-sample forecasts?

The design is in [DESIGN.md](DESIGN.md). It is a draft and has not been frozen yet.

## Data

| File | Country | Period | Units | Source |
|---|---|---|---|---|
| `data/bd_remittances_monthly.csv` | Bangladesh | Jul 2009 to Jul 2026 | US$ million (`remittances_usd_mn`); Tk crore also given | Bangladesh Bank, *Monthly Economic Trends*, compiled across issues with vintage tracking (`n_vintages`, `source_issue`) |
| `data/pk_remittances_monthly.csv` | Pakistan | Jul 2005 to Dec 2024 | US$ million, original (`remittances_usd_mn`) and SBP seasonally adjusted (`remittances_sa_usd_mn`) | State Bank of Pakistan, *Workers' Remittances (Credit), Seasonally Adjusted* (file "SA workers' Remittances Nov24.xlsx", printed 9 Jan 2025) |

Notes:
- Use the original Pakistan series. The SBP seasonal adjustment method is not documented in the source file and may already remove Eid effects.
- Pakistan data from Jan 2025 onward are published only on SBP EasyData and have not been added yet.
- Both series come from public central-bank publications. Check each source's terms of reuse before redistributing further.

## Layout

```
data/      input series (and, later, Eid dates)
scripts/   one script per analysis step
results/   tables and figures produced by the scripts
```
