# Data documentation (Phase 1)

Prepared 4 Nov 2026. This file covers the "document before analysis" list in DESIGN.md §3. It describes the inputs only; no model has been fitted.

## 1. Remittance series

| | Bangladesh | Pakistan |
|---|---|---|
| File | `data/bd_remittances_monthly.csv` | `data/pk_remittances_monthly.csv` |
| Series used | `remittances_usd_mn` | `remittances_usd_mn` (original, not seasonally adjusted) |
| Definition | Remittances as printed in Bangladesh Bank, *Monthly Economic Trends* (Tables XX, XXI and XVIII in different issues) | State Bank of Pakistan, Workers' Remittances (Credit) |
| Currency, units | US$ million (Tk crore column also present, not used) | US$ million, rounded to whole millions |
| Span in file | Jul 2009 – Jul 2026 (205 months) | Jul 2005 – Dec 2024 (234 months) |
| Primary analysis span | Jul 2009 – Jun 2026 (204 months). Jul 2026 is excluded: single vintage, preliminary | Jul 2005 – Dec 2024 (234 months) |
| Seasonal adjustment | None (raw) | None in the column used. The file also has SBP's SA series (`remittances_sa_usd_mn`); it is not used because SBP does not document its method and it may already remove Eid effects |
| Revisions | Each month is taken from the latest issue that prints it. `n_vintages` counts how many issues printed it (1–6); `source_issue` gives the issue used. 24 months (Jul 2024 onward) have ≤2 vintages and may still be revised | One vintage: SBP file "SA workers' Remittances Nov24.xlsx", printed 9 Jan 2025 |
| Missing months / duplicates / non-positive | 0 / 0 / 0 | 0 / 0 / 0 |
| Provisional or revised flags | None printed (`flag_P` = "none printed" for all rows; `flag_R_printed` empty) | None in source |

Observations:
- **Unit label change (BD).** The unit label changes from "Million US. $" (48 rows, to Jun 2013) to "Million US $" (157 rows). It is the same unit; no level break is expected from it.
- **Unrounded values (BD).** Six recent BD values carry long decimals (Sep 2025, Jan–Mar 2026, May 2026, Jul 2026), which suggests they were computed in the source workbook rather than typed. Other long decimals in the file are floating-point artefacts (e.g. 1230.5700000000002). None of this needs action.
- **Rounding difference.** PK values are whole US$ millions, BD values have two decimals. On the log scale the rounding error is under 0.1% for PK, which is negligible.
- **Spans differ by design.** Per the decision of 4 Nov 2026, each country uses its full span. The common window (Jul 2009 – Dec 2024, 186 months) is used only as a sensitivity check for the cross-country coefficient test.
- **PK after Dec 2024.** Data from Jan 2025 onward exist on SBP EasyData but have not been added. Adding them would change the PK sample and has to be decided before the design is frozen.

## 2. Eid dates

File: `data/eid_dates.csv`, built by `scripts/00_build_eid_dates.py` from the source log `data/eid_dates_sources_raw.tsv`.

**Coverage.** One row per country × event × Hijri year, 1426–1447 AH (Nov 2005 – May 2026). `in_sample = 1` when any day of a 30-day window ending on that Eid falls inside the country's data span.

**What counts as the local date.** The first day of Eid as declared nationally:
- Bangladesh: the National Moon Sighting Committee (Islamic Foundation), as reported in the press.
- Pakistan: the Central Ruet-e-Hilal Committee.

Two things are deliberately not used:
- Public-holiday blocks (e.g. State Bank of Pakistan closure notices) are not treated as Eid dates.
- Regional early celebrations are ignored. These include villages in Bangladesh that follow Saudi Arabia, and Khyber Pakhtunkhwa/Peshawar declarations in Pakistan in 2011, 2012, 2015, 2019 and 2021.

**Status column:**

| status | Meaning | In-sample BD | In-sample PK |
|---|---|---|---|
| `sourced` | Date taken from a contemporaneous news report of the official announcement, or from the ICOP official list | 31 | 30 |
| `sourced_secondary` | Weaker source: photojournalist captions (BD Fitr 2011, 2012; BD Adha 2011) | 3 | 0 |
| `fallback_umm_al_qura` | No announcement-level source found; Umm al-Qura date used and flagged | 2 | 10 |
| **Total in-sample events** | | **36** | **40** |

**In-sample fallbacks:**
- BD: Fitr 1430 (Sep 2009), Adha 1433 (Oct 2012).
- PK: Fitr 1426, 1428, 1429, 1430, 1434; Adha 1426, 1427, 1428, 1429, 1432.

The PK fallbacks are concentrated in 2005–2009. For most of them an SBP holiday notice gives the closure block, recorded in `note`. Those blocks always cover the Umm al-Qura date or the day after it.

**Checks done:**
- *Weekday check.* Every source that names a weekday matches the weekday of the recorded date. The two apparent mismatches are notes naming a different day, e.g. the Saudi Eid day.
- *Distance from Umm al-Qura.* Among sourced dates, the local Eid falls 0 days after Umm al-Qura (5 PK cases), 1 day after (59 cases) or 2 days after (8 cases).
  - All +2 cases are years when Saudi Arabia itself departed from the Umm al-Qura calendar: Fitr 2006, Adha 2014, 2015 and 2016.
  - In those years the BD and PK sources agree with each other.
- *Implication.* An Umm al-Qura fallback can therefore be off by up to 2 days, not only 1.
- *Sensitivity to the date choice.* With a 21-day window, using Umm al-Qura instead of local dates changes a month's exposure by at most 2/21 = 0.095. That happens in 22 BD months and 12 PK months.

**Bangladesh–Pakistan differences (sourced, same Hijri event).** Both dates are sourced for 32 events. The two countries agree on 27 of them. In the other 5, Pakistan is one day earlier:
- Fitr: 2016, 2020, 2021, 2024.
- Adha: 2026.

A shared calendar would therefore be wrong for one of the two countries in exactly the years where the comparison is most informative.

**Not covered.** The Bangladesh announcements for 2005–2008 are outside the BD span and were collected only incidentally.

## 3. Exposure regressors

File: `data/eid_exposure_monthly.csv`, built by `scripts/01_eid_exposure.R`.

**Definition.** Exposure of month *m* = (number of window days falling in *m*) / *L*. The window is *L* days ending on Eid day, inclusive. Fitr and Adha are separate regressors.

| Column suffix | Window |
|---|---|
| `_w21` | Primary: 21 days ending on Eid day (same as all earlier BD results) |
| `_w10`, `_w30` | Sensitivity: window length |
| `_w21_pre` | Sensitivity: 21 days ending the day before Eid |
| `_w21_uq` | Sensitivity: 21 days ending on Umm al-Qura Eid (local-vs-Umm-al-Qura check) |

**Built-in checks** (the script stops if any fails):
- Every value lies in [0, 1].
- Fitr and Adha 30-day windows never overlap.
- Each event fully inside the span contributes exactly 1 in total.

Hand check: BD Fitr 11 Apr 2024 gives Mar = 10/21, Apr = 11/21.

## 4. Sources for the Eid dates

The full per-event citations are in `data/eid_dates.csv` (`source` column). The main outlets are:
- **Bangladesh:** The Daily Star, Dhaka Tribune, The Financial Express, Prothom Alo, UNB, banglanews24, The Business Standard.
- **Pakistan:** Dawn, Express Tribune, Geo, ARY, APP, Dunya, Aaj, Daily Pakistan.
- **Cross-country:** ICOP (International Astronomical Center) Shawwal 1431 page; ummid.com for 2017 and 2019.

Umm al-Qura dates come from the `hijri-converter` package (v2.3, Umm al-Qura tables).
