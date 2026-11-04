# Confirmatory run: results (corrected)

**Version 2, 4 Nov 2026.**
- Plan: `DESIGN.md` v1.0, pre-specified and date-stamped (commit 683f560).
- This version replaces the run-1 report (commit c62ac69).
- A coding error in the intervention rule was found after run 1 (deviation 2, §8). It was fixed and every affected configuration rerun.
- Run-1 tables are kept in `results/archive_before_fix1/`.
- Analysis chronology and disclosure: [`docs/CHRONOLOGY.md`](../docs/CHRONOLOGY.md).

**Labels.**
- Each section is split into **Observed**, **Interpretation** and **Unresolved**.
- Sections 1b, 2b, 2c and 5 are **post hoc**. They were requested on 4 Nov 2026 after run 1 and are not part of the pre-specified plan.

---

## 0. What changed between run 1 and this version

| | Run 1 | Corrected |
|---|---|---|
| BD interventions (full sample) | LS Jun 2020 | LS Mar 2020 + LS Jun 2020 (both B2) |
| PK interventions (full sample) | LS Jun 2020 | AO Oct 2008 (P1) + LS Jun 2020 (P4) |
| PK orders (full sample) | (0,1,1)(1,0,0)+drift | (3,1,1)(1,0,0)+drift |
| BD Fitr / Adha % | 13.2 / 16.8 | 13.8 / 16.6 |
| PK Fitr / Adha % | 13.9 / 12.8 | 14.5 / 11.3 |
| Cross-country p (Fitr / Adha) | 0.88 / 0.37 | 0.87 / 0.22 |
| CW t, Holm p: BD h1 | 3.00, 0.004 | 3.03, 0.004 |
| CW t, Holm p: BD h3 | 2.58, 0.005 | 2.56, 0.009 |
| CW t, Holm p: PK h1 | 2.81, 0.005 | 2.61, 0.009 |
| CW t, Holm p: PK h3 | 3.10, 0.004 | 3.14, 0.003 |
| RMSE improvement h1 / h3: BD | 7.0 / 3.9 | 6.7 / 4.4 |
| RMSE improvement h1 / h3: PK | 6.1 / 5.8 | 5.2 / 5.4 |
| B5 (Aug 2024) selected? | no | **no** (full sample and every origin) |

No conclusion changes. The four confirmatory Clark–West tests reject after Holm in both versions.

---

## 1. RQ1: Eid effects (full-sample RegARIMA, log remittances)

### 1a. Pre-specified results

**Observed**

| | Orders | Interventions | Fitr % [95% CI] | Adha % [95% CI] |
|---|---|---|---|---|
| BD, Jul 2009 – Jun 2026 (n = 204) | (0,1,1)(0,0,1) | LS Mar 2020, LS Jun 2020 [B2] | 13.8 [7.5, 20.4] | 16.6 [10.1, 23.5] |
| PK, Jul 2005 – Jun 2026 (n = 252) | (3,1,1)(1,0,0)+drift | AO Oct 2008 [P1], LS Jun 2020 [P4] | 14.5 [9.2, 20.1] | 11.3 [6.0, 16.8] |

- **Cross-country difference** (BD − PK, log points):
  - Fitr: −0.006 (SE 0.038), p = 0.87.
  - Adha: +0.047 (SE 0.038), p = 0.22.
- **S10, common window** (ρ̂ = 0.45): Fitr p = 1.00; Adha p = 0.71.
- **Stability (S8)**, Post = Jul 2020: Wald p = 0.79 (BD), 0.99 (PK).
- **Diagnostics:**
  - BD: Ljung–Box(24) p = 0.060; Jarque–Bera p = 0.50.
  - PK: Ljung–Box(24) p = 0.0003; Jarque–Bera p = 0.32.

**Sensitivities (Fitr % / Adha %):**

| Spec | BD | PK |
|---|---|---|
| Primary | 13.8 / 16.6 | 14.5 / 11.3 |
| S1 w10 | 7.5 / 11.6 | 6.2 / 7.9 |
| S1 w30 | 19.6 / 20.5 | 19.6 / 14.9 |
| S2 day before Eid | 14.6 / 17.4 | 15.2 / 11.9 |
| S3 Umm al-Qura | 14.4 / 17.5 | 14.6 / 11.4 |
| S4 airline | 13.1 / 18.6 | 10.3 / 10.9 |
| S5 no interventions | 10.9 / 19.1 | 12.9 / 13.0 |
| S6 automatic outliers | 12.9 / 15.8 | 11.9 / 12.4 |
| S9 PK to Sep 2026 | — | 14.5 / 11.2 |
| S10 common window | — | 13.8 / 15.4 |

All 95% CIs exclude 0.

**Interpretation**
- A full-window Eid month is associated with roughly 11–17% higher remittances in both countries, for both Eids.
- No cross-country difference is detected. The test could only detect differences of about 0.11 log points (80% power), so smaller differences remain possible.
- The effect scales with window length (w10 < w21 < w30). The w21 coefficient is a property of the chosen exposure definition, not "the" Eid effect.

### 1b. PK inference under residual autocorrelation (post hoc)

The PK primary residuals fail Ljung–Box (lags 13, 14, 35). This was checked in three ways (`scripts/07_pk_inference.R`; outputs in `results/posthoc/pk_inference_*.csv`). BD is run through the same code for comparison.

**Observed**

**1. Can the residuals be whitened by a different error model?** (PK; Eid β with SE)

| Error model | AICc | LB12 p | LB24 p | LB36 p | Fitr β (SE) | Adha β (SE) |
|---|---|---|---|---|---|---|
| Primary (3,1,1)(1,0,0)+drift | −510 | 0.20 | 0.0003 | 0.0004 | 0.135 (0.024) | 0.107 (0.025) |
| (0,1,1)(1,0,1)+drift | −504 | 0.03 | <0.001 | <0.001 | 0.121 (0.026) | 0.118 (0.026) |
| (0,1,1)(2,0,0)+drift | −505 | 0.03 | <0.001 | <0.001 | 0.122 (0.026) | 0.118 (0.026) |
| Airline (0,1,1)(0,1,1) | −464 | <0.001 | <0.001 | <0.001 | 0.098 (0.020) | 0.103 (0.022) |
| (2,1,2)(1,0,1)+drift | −508 | 0.21 | 0.0004 | 0.0004 | 0.133 (0.024) | 0.095 (0.025) |
| Subset MA{1,13,14} + primary seasonal | **−518** | 0.15 | 0.018 | 0.011 | 0.131 (0.025) | 0.105 (0.026) |

No standard error model removes the autocorrelation. The best by AICc, a subset MA with lags 13 and 14, reduces it but still fails at 24 and 36 lags.

**2. HAC standard errors on the GLS-whitened regression.**
- Method: y and every regressor are filtered through the estimated ARIMA filter, the whitened regression is fitted by OLS, and the SEs are then made robust to any remaining autocorrelation.
- A moving-block bootstrap of the whitened residuals is shown as a check.

| SE type | PK Fitr SE (p) | PK Adha SE (p) | BD Fitr SE | BD Adha SE |
|---|---|---|---|---|
| Model-based ML (as reported) | 0.024 (3e-8) | 0.025 (2e-5) | 0.029 | 0.029 |
| Newey–West, automatic bandwidth | 0.031 (1e-5) | 0.029 (2e-4) | 0.033 | 0.026 |
| Newey–West, prewhitened | 0.034 (6e-5) | 0.027 (9e-5) | 0.031 | 0.028 |
| Andrews QS kernel, prewhitened | **0.034** (7e-5) | 0.028 (1e-4) | 0.031 | 0.033 |
| Moving-block bootstrap (L = 24) | 0.025 (7e-8) | 0.025 (1e-5) | 0.032 | 0.031 |

- The most conservative PK SEs are 1.4× the model-based value for Fitr and 1.2× for Adha.
- Every PK and BD Eid effect stays significant at p ≤ 2e-4 under every SE type.

**3. Cross-country test under each SE type:**
- Fitr p ranges from 0.86 to 0.89.
- Adha p ranges from 0.14 to 0.27.

**Interpretation**
- The autocorrelation is real and is not removed by richer ARMA error models.
- **Point estimates.** The PK Eid point estimates are stable across error models (Fitr 0.12–0.135 except the airline model; Adha 0.095–0.118).
- **Standard errors.** The PK model-based SEs are understated, by up to about 30% for Fitr. HAC-corrected inference does not change any conclusion: the Eid effects remain clearly non-zero and no cross-country difference is detected.
- **For the paper.** Report the model-based SEs with the HAC range alongside, or use the prewhitened QS SEs as the conservative headline.
- **The lag-36 Newey–West SE** (not shown in the table; see `pk_inference_hac.csv`) behaves erratically for BD Adha (0.015). It is not used.

**Unresolved**
- The source of the lag 13/14/35 structure. One candidate is a moving-holiday echo: Eid shifts about 11 days a year, so adjacent-month spill-over recurs at about 12–13 months.
- A richer exposure model (e.g. separate pre- and post-Eid month terms) might remove it. This is not tested here, because it would be a new specification.

---

## 2. RQ2: do Eid regressors improve forecasts? (expanding window, targets Jul 2017 – Jun 2026)

### 2a. Pre-specified results

**Observed**

**Confirmatory tests** (Clark–West, one-sided, Holm over 4 tests):

| | n | CW t | raw p | Holm p | Reject at 5% |
|---|---|---|---|---|---|
| BD h1 | 108 | 3.03 | 0.0012 | 0.0036 | yes |
| BD h3 | 106 | 2.56 | 0.0053 | 0.0090 | yes |
| PK h1 | 108 | 2.61 | 0.0045 | 0.0090 | yes |
| PK h3 | 106 | 3.14 | 0.0008 | 0.0033 | yes |

**Secondary tests** (Diebold–Mariano, absolute loss, two-sided):
- BD h1 p = 0.023; BD h3 p = 0.052.
- PK h1 p = 0.12; PK h3 p = 0.13.

**Size of the gain:**
- RMSE improvement (log scale), BD: 6.7% (h1), 4.4% (h3), 3.2% (h6), 0.9% (h12).
- RMSE improvement, PK: 5.2%, 5.4%, 3.7%, 0.5%.
- The 95% HAC intervals for ΔMSE contain 0 in all four cells (BD h1 lower bound −0.00002).
- The ΔMAE interval excludes 0 for BD h1 and BD h3 only.

**Clark–West at other horizons:**
- p < 0.05 at every horizon h = 1–12 for BD (smallest t: h9 1.84, h12 1.90).
- p < 0.05 at h = 1–9 for PK (h10 t = 1.62, h11 1.64, h12 1.30).

**Benchmarks, h1** (RMSE log, MAE log, ME log):

| | BD | PK |
|---|---|---|
| Baseline | 0.138, 0.107, +0.015 | 0.105, 0.083, −0.004 |
| Eid | **0.129**, **0.099**, +0.015 | **0.100**, **0.078**, −0.000 |
| Box–Jenkins (0,1,1)(1,1,1) | 0.137, 0.106, +0.012 | 0.102, 0.080, −0.008 |
| Seasonal naive | 0.220, 0.183, +0.113 | 0.182, 0.148, +0.085 |

- The Eid model has the lowest RMSE of the four models at h = 1, 3 and 6 in both countries. At h = 12 the Box–Jenkins model is marginally better for BD (0.212 vs 0.212).
- **BD bias:** mean error is positive and grows with horizon (+0.015, +0.025, +0.048, +0.083 at h = 1, 3, 6, 12). PK bias is about 0.

**Interpretation**
- **RQ2: yes, under the pre-specified test.** The Eid regressors add predictive content at 1 and 3 months in both countries, after the multiplicity correction.
- **The realised accuracy gain is modest** (about 4–7% RMSE at h ≤ 3) and imprecisely estimated (ΔMSE intervals contain 0). Diebold–Mariano is significant only for BD h1. Clark–West tests whether the Eid coefficients carry signal; Diebold–Mariano tests whether this estimated model wins in this sample. The results answer the first question with "yes" and the second with "barely".
- **The gain fades with horizon,** to about 0 at h = 12.

### 2b. Forecast-test inference with wider HAC lags (post hoc)

**Why this was checked:** the primary Clark–West variance uses h − 1 Newey–West lags (0 lags at h = 1). That is valid only if the loss differentials are serially uncorrelated beyond h − 1.

**Observed** (`results/posthoc/fc_hac.csv`)
- The Clark–West loss series shows no autocorrelation: Ljung–Box(12) p = 0.85, 0.74 for BD h1, h3, and 0.18, 0.42 for PK h1, h3.
- CW t across lag choices:

  | | Primary lags | Range across 6, 12 lags, automatic, prewhitened, QS |
  |---|---|---|
  | BD h1 | 3.03 | 3.37 – 4.21 |
  | BD h3 | 2.56 | 2.57 – 3.60 |
  | PK h1 | 2.61 | 2.45 – 3.35 |
  | PK h3 | 3.14 | 3.07 – 3.72 |

- Largest Holm p across all variants: 0.010.

**Interpretation:** the forecast tests are not affected by the PK residual autocorrelation. Wider HAC windows leave every rejection in place; in most cells they make the t-statistic larger.

### 2c. July 2020 (post hoc; the primary analysis is unchanged)

**Observed** (`results/posthoc/fc_jul2020.csv`, `fc_loo*.csv`)

| | Full sample (primary): n, CW t, Holm p, RMSE improvement | EXPLORATORY, Jul 2020 target excluded: n, CW t, Holm p, RMSE improvement |
|---|---|---|
| BD h1 | 108, 3.03, 0.004, 6.7% | 107, 3.05, 0.005, 5.1% |
| BD h3 | 106, 2.56, 0.009, 4.4% | 105, 1.99, 0.023, 1.9% |
| PK h1 | 108, 2.61, 0.009, 5.2% | 107, 2.39, 0.021, 4.0% |
| PK h3 | 106, 3.14, 0.003, 5.4% | 105, 2.46, 0.021, 4.2% |

**Influence of Jul 2020:**
- Jul 2020 (Eid al-Adha on 1 Aug 2020, so the 21-day window falls almost entirely in July) is the single largest contributor to the squared-error reduction in all four cells.
- Its share of the total reduction: 32% (BD h1), 63% (BD h3), 27% (PK h1), 26% (PK h3).

**Leave-one-target-month-out** (each of the about 106–108 target months dropped in turn):
- The smallest CW t is 2.85 (BD h1, dropping Mar 2025), 1.99 (BD h3, dropping Jul 2020), 2.39 (PK h1, Jul 2020) and 2.46 (PK h3, Jul 2020).
- No single exclusion takes any cell below t = 1.645.

**Where the gain falls:** split by whether the target month has Eid exposure, h1 RMSE improves 13.3% in Eid months vs 2.7% in other months (BD), and 9.5% vs 1.4% (PK).

**Interpretation**
- The primary result stands with Jul 2020 included. The exclusion is reported as exploratory, not as a replacement.
- Without Jul 2020, all four Clark–West tests still reject after Holm, so no single month carries the confirmatory conclusion.
- The *size* of the gain is another matter. Without Jul 2020, the BD h3 gain falls from 4.4% to 1.9%, and Jul 2020 alone supplies 63% of that cell's loss reduction.
- The paper should report both rows and say that the magnitude of the forecast improvement, especially BD h3, depends heavily on one COVID-period Eid month.

---

## 3. Training window and later periods (§8; S7, S8)

**Observed** — Eid gain by window strategy, as RMSE improvement % / CW t:

| | Expanding | Rolling 60 | Rolling 96 | Rolling 120 (targets ≥ Jul 2019) | Expanding (targets ≥ Jul 2019) |
|---|---|---|---|---|---|
| BD h1 | 6.7 / 3.03 | 3.2 / 2.59 | 4.9 / 2.70 | 5.9 / 2.43 | 6.4 / 2.51 |
| BD h3 | 4.4 / 2.56 | 4.0 / 2.58 | 1.5 / 2.16 | −0.5 / 1.05 | 4.2 / 2.25 |
| PK h1 | 5.2 / 2.61 | 3.5 / 2.19 | 6.1 / 2.47 | 2.3 / 1.45 | 2.7 / 1.79 |
| PK h3 | 5.4 / 3.14 | 3.9 / 2.72 | 4.8 / 2.74 | 3.5 / 2.19 | 4.6 / 2.54 |

**Baseline RMSE, expanding vs rolling 60 / 96:**
- h1: BD 0.138 vs 0.145 / 0.143; PK 0.105 vs 0.118 / 0.115.
- h3: BD 0.163 vs 0.180 / 0.168; PK 0.120 vs 0.134 / 0.133.
- Rolling 120 vs expanding, same targets: BD h1 0.147 vs 0.143; PK h1 0.114 vs 0.103.

**Split at Jul 2020**, RMSE improvement % (CW t):

| | Before Jul 2020 (34–36 targets) | From Jul 2020 (72 targets) |
|---|---|---|
| BD h1 | 3.6 (1.88) | 8.6 (2.54) |
| BD h3 | −2.7 (0.04) | 7.5 (2.62) |
| PK h1 | 1.6 (0.86) | 8.0 (2.76) |
| PK h3 | 0.1 (0.58) | 7.6 (3.13) |

**Interpretation**
1. **Rolling vs expanding:** rolling windows never beat the expanding window on the baseline.
2. **Earlier vs later errors:** baseline errors are smaller after Jul 2020 at h1 in both countries, and larger at h3. Per the plan, this is not read as evidence that recent data are better.
3. **Gap after the selected interventions:** the Eid gain is almost entirely a post-Jul-2020 phenomenon. Before Jul 2020 there are 3 years and about 6 Eid events, with gains near 0. The COVID interventions enter at origins Jun – Sep 2020, so "after the interventions" and "after Jul 2020" cannot be separated.
4. **Does the window change the Eid gain?** Yes, at the margin. The expanding window gives the largest gain in 3 of 4 cells. The 120-month window removes the BD h3 gain entirely. This fits the Eid coefficients needing long histories to be estimated well, because they are identified from Eid moving through the calendar.
5. **Coefficients stable, forecast gains not:** the Eid coefficients show no change after Jul 2020 (§1a), but the forecast gain appears only after Jul 2020. This is not explained here. The candidates are small-sample noise before 2020 (about 6 events) and Jul 2020 itself (§2c).

---

## 4. Sensitivities on forecasting (S1–S6, S9)

Clark–West t (uncorrected one-sided, the convention for sensitivities) and RMSE improvement %:

| Spec | BD h1 | BD h3 | PK h1 | PK h3 |
|---|---|---|---|---|
| Primary | 3.03, 6.7 | 2.56, 4.4 | 2.61, 5.2 | 3.14, 5.4 |
| S1 w10 | 2.95, 4.3 | 2.18, 3.4 | 1.66, 2.0 | **1.54**, 1.2 |
| S1 w30 | 3.30, 9.8 | 2.09, 2.1 | 3.66, 11.6 | 3.66, 9.2 |
| S2 day before Eid | 2.96, 7.3 | 1.84, 1.0 | 3.03, 7.4 | 3.32, 6.3 |
| S3 Umm al-Qura | 2.96, 7.4 | 1.90, 1.1 | 3.00, 6.9 | 3.28, 6.0 |
| S4 airline orders | 3.28, 8.7 | 2.95, 3.4 | 2.20, 2.8 | 2.00, 0.3 |
| S5 no interventions | 2.93, 6.3 | 1.95, 2.6 | 2.73, 5.7 | 3.27, 6.2 |
| S6 automatic outliers | 2.71, 4.3 | **1.39**, 0.3 | 2.87, 6.2 | 3.04, 5.3 |
| S9 PK to Sep 2026 | — | — | 2.62, 5.2 | 3.16, 5.4 |

**Observed**
- At h1, CW t > 1.645 in every sensitivity, in both countries.
- At h3, two cells fall below 1.645: PK S1 w10 (t = 1.54) and BD S6 (t = 1.39).
- RMSE improvement is ≤ 1.2% in five h3 cells: BD under S2, S3 and S6; PK under S1 w10 and S4.
- S5 and S6 were not affected by deviation 2 and are unchanged from run 1.
- S6 BD selects a median of 6 automatic outliers per origin (27 at origin Aug 2020).

**Interpretation**
- **The h1 result is robust** to dates, window position, orders, the intervention rule and sample end.
- **The h3 result is weaker, most of all for BD.** The BD h3 improvement is about 1% under S2, S3 and S6, and the BD h3 gain also depends heavily on Jul 2020 (§2c). Of the four confirmatory cells, BD h3 is the most fragile.
- **A 10-day window** is too short to capture the PK pre-Eid pattern.
- **Fully automatic outlier detection** is unstable at series ends just after large shocks. This supports the pre-specified requirement of an external reason for each intervention.
- These sensitivities were not used to choose a specification.

---

## 5. Bangladesh Aug 2024 break (post hoc)

### 5a. Genuine shift or reporting issue?

**Observed — data checks:**
- **First release vs current vintage.** Bangladesh Bank's first-released Aug 2024 figure, as reported on 1–2 Sep 2024, was $2.22 bn: +39% y/y and +16% on Jul 2024 ($1.91 bn). The series used here (vintage ET-2026-08, 5 vintages) has 2,224.15, so the figure has not been revised.
- **Annual totals.** The series sums to $23,912 m for FY24 and $30,329 m for FY25. These match Bangladesh Bank's published totals ($23.91 bn and $30.32–30.33 bn).
- **Units.** The Tk/US$ rate implied by the two units moves smoothly (110 → 115 → 118 → 120 → 122, May 2024 – Mar 2025). There is no unit or conversion break in the US$ series.
- **Compilation change.** No change in compilation or coverage was found in Bangladesh Bank's releases or press reporting for 2024–25. Bangladesh Bank and bankers attribute the rise to:
  - a narrower formal–kerb exchange-rate gap (crawling peg from May 2024, market-based rate from 2025);
  - a crackdown on hundi networks after the change of government on 5 Aug 2024.
- **Jul 2024 was itself abnormal.** Banking was suspended 18–23 Jul 2024 during the internet shutdown, and expatriates ran a "remittance shutdown" campaign. Inflows fell to $78 m over 19–24 Jul.

**Observed — statistics** (`scripts/06_bd_2024_break.R`, `results/posthoc/bd2024_*.csv`):
- **LS Aug 2024 t-statistic:** 2.72 on the rule's airline detection model and 2.27 on the primary orders. The critical value is cval(204) = 3.38, so the rule correctly does not select it.
- **Estimated size:** +0.16 log points (≈ +17%).
- **Other months in the B5 window (Aug–Oct 2024):** the largest |t| is 2.72. AO Jul 2024 (not a candidate) has t = −2.0.
- **Months with larger t in Jan 2023 – Mar 2026:** AO Sep 2023 (t −4.0 on the primary orders) and LS Oct 2023 (3.35). Neither is a candidate.
- **Competing descriptions** (primary orders + rule-selected interventions + Eid; AICc):

  | Description | AICc | Δ vs none |
  |---|---|---|
  | None | −363.1 | — |
  | LS Aug 2024 | −366.0 | **−2.9** |
  | AO Jul 2024 + LS Aug 2024 | −365.0 | −1.9 |
  | AO Jul 2024 | −364.8 | −1.7 |
  | Ramp Aug 2024 – Mar 2025 | −362.7 | +0.4 |
  | Trend change from Aug 2024 | −362.7 | +0.4 |

  The Eid estimates barely move under any of these.
- **Residuals.** Primary-model residuals average +0.030 after Aug 2024 (23 months, t = 1.49), compared with +0.017 over Jul 2022 – Jul 2024.

**Interpretation**
- **Genuine, not a reporting artefact.** The figure is unrevised, it reconciles with the published annual totals, there is no unit break, and there is a documented economic mechanism.
- **Statistically it is a modest step,** about +17%, with t ≈ 2.3–2.7. That is real in the data but well below the pre-specified threshold, and the model with the step is only mildly preferred (ΔAICc ≈ 3).
- **Much of the 2024–26 rise is gradual.** FY25 grew +27% and FY26 +17%. This is better described as continued strong growth than as a single level shift.

### 5b. Does accounting for it change the forecasting results?

Two post hoc configurations force the break into the intervention set once 3 post-event observations are in the training window (the same entry rule as the candidates):
- `X_B5_LS`: LS Aug 2024, entering at origin Nov 2024.
- `X_B5_AO_LS`: AO Jul 2024 + LS Aug 2024.

Everything else is identical to the primary.

**Observed** (`results/posthoc/bd2024_forecast_compare.csv`):

**All targets:**

| | ME base: primary / LS / AO+LS | Eid RMSE improvement: primary / LS / AO+LS | CW t: primary / LS / AO+LS |
|---|---|---|---|
| h1 | 0.015 / 0.016 / 0.016 | 6.7 / 6.6 / 6.7 | 3.03 / 3.02 / 3.07 |
| h3 | 0.026 / 0.028 / 0.027 | 4.4 / 4.1 / 4.3 | 2.56 / 2.51 / 2.57 |
| h6 | 0.048 / 0.052 / 0.050 | 3.2 / 2.9 / 3.0 | 2.79 / 2.63 / 2.69 |
| h12 | 0.083 / 0.087 / 0.085 | 0.9 / 0.9 / 0.8 | 1.90 / 1.92 / 1.78 |

**Targets from origins ≥ Nov 2024** (n = 19, 17, 14, 11 and 8 at h = 1, 3, 6, 9, 12; overlapping):

| | Baseline ME: primary → LS | Baseline RMSE: primary → LS |
|---|---|---|
| h1 | 0.027 → 0.034 | 0.121 → 0.118 |
| h6 | 0.071 → 0.099 | 0.127 → 0.139 |
| h12 | 0.138 → 0.187 | 0.167 → 0.206 |

**Interpretation**
- **Accounting for the break does not change any RQ2 conclusion.** The Eid gain and the Clark–West statistics are essentially identical.
- **It does not fix the long-horizon underforecast either; it makes it slightly worse.** A level-shift dummy absorbs the 2024 step as a one-off. The underforecast comes from the growth that continued after the step, which these driftless models cannot project.
- **What the paper can say:** the BD long-horizon bias reflects sustained post-2024 growth, not a missed level shift. The post-2024 evaluation sample is very small: 8 overlapping targets at h = 12.

**Unresolved**
- Whether a drift term, or a growth-rate change, from 2024 would remove the bias. This would be a further post hoc specification, and it was not run, per the instruction to prioritise these four items over further robustness checks.
- AO Sep 2023 and LS Oct 2023 (t −4.0 and 3.35) are larger than the Aug 2024 break and have no candidate. They were not investigated.

---

## 6. Analysis chronology (disclosure)

The full timeline, the choices informed by earlier results, and suggested wording for the paper are in [`docs/CHRONOLOGY.md`](../docs/CHRONOLOGY.md). In brief:
- The Bangladesh M.Sc. thesis analysed the same series in Oct 2026. It supplied the 21-day window, the Jul 2020 split, the Clark–West-primary design, and the observation that gains are larger at short horizons. That observation is why h = 1 and 3 are focal; they are exploratory choices, not strictly pre-specified.
- Pakistan in-sample Eid estimates, an airline forecast comparison and an outlier search were seen before the plan was fixed.
- **Consequences:**
  - The BD results are a re-analysis, not an independent test.
  - The PK results are a partial replication of a Bangladesh-informed design.
  - Only the elements fixed in commit 683f560 are pre-specified.
  - Everything in §§1b, 2b, 2c and 5 is post hoc.

---

## 7. Limitations to state in the paper
1. **Prior exploratory analyses** (§6). BD is a re-analysis; PK is a partial replication; h = 1 and 3 were chosen in exploration.
2. **The magnitude of the forecast gain rests on few events.** Jul 2020 supplies 26–63% of the loss reduction. The confirmatory tests survive its exclusion, but the BD h3 gain falls to 1.9%.
3. **PK residual autocorrelation.** Model-based SEs are understated by up to about 30%. Conclusions hold under HAC and bootstrap SEs (§1b).
4. **BD long-horizon underforecast** after 2024 comes from sustained growth that the models do not capture. The Aug 2024 break is genuine but below the pre-specified threshold, and adding it does not help (§5).
5. **Unstable PK intervention selection around COVID.** At the PK forecast origins, the rule switches between AO, TC and LS for May/Jun 2020, and it adds or drops AO Oct 2008 and AO Jul 2016 from origin to origin (see the `interventions` column in the forecast files). This is how the rule behaves; it is not changed.
6. **Outliers outside the candidate list.** BD Sep 2017, Sep/Oct 2023 and the PK Oct 2022 LS are found only by automatic detection or the post hoc scan. The candidate list was not widened.
7. **Eid date quality.** Umm al-Qura fallbacks were used for BD 2 of 36 and PK 10 of 44 events, and 3 BD dates come from captions. S3 shows the results are insensitive to the date source.
8. **PK vintage break** at Jan 2025, and Aug 2026 is a derived figure (`DATA.md` §1a).
9. **In-house outlier code.** It matches `tso` on the full-sample check but has not been validated at every origin.

## 8. Deviations (code defects found after run 1; `DESIGN.md` log)
- **Deviation 1 (cache filename length).** One S6 BD origin was dropped and the drop was not counted. Fixed and rerun. S6 BD h1 CW t: 2.72 → 2.71.
- **Deviation 2 (seasonal frequency in `select_interventions`).**
  - The rule's candidate t-tests were run on a non-seasonal ARIMA(0,1,1) instead of the airline model, because the series lacked a monthly frequency attribute.
  - Fixed, and RQ1 plus every configuration using the candidate rule were rerun (primary, rolling windows, S1–S4, S9, S10). S5 and S6 were not affected.
  - Before and after are in §0. Run-1 tables are in `results/archive_before_fix1/`.
- **Container restart.** The machine restarted during the rerun. Seven configurations were restarted from the cache; this has no effect on results.
