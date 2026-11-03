# Pre-specified analysis plan v1.0

**Date-stamped 4 Nov 2026.** This plan is fixed before any confirmatory model is fitted. The commit that introduces this version is the date stamp. Any later change goes in the deviations log at the end, with its date and reason. The 3 Nov working draft is kept in `docs/design_draft_2026-11-03.md`.

**Title:** *Islamic-Calendar Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan*

**Disclosure.** Exploratory analyses were run before this plan was fixed:
- **Bangladesh:** the M.Sc. thesis plan v1.1 and its post hoc checks.
- **Pakistan:** in-sample Eid estimates and a paired forecast comparison using airline SARIMA models.

The Pakistan analysis is therefore a replication of a design informed by Bangladesh, by someone who had already seen some Pakistan results. The paper must say so. The focal horizons h = 1 and 3 are exploratory choices informed by the earlier Bangladesh results; they are not pre-specified in the strict sense.

---

## 1. Research questions

**RQ1 — Effect estimation.**
- Are Eid al-Fitr and Eid al-Adha associated with changes in monthly workers' remittances in Bangladesh (BD) and Pakistan (PK)?
- Do the size and direction of these effects differ between the two countries?

**RQ2 — Forecasting value.**
- Do Eid regressors improve out-of-sample forecasts in each country?
- Secondary: do the effects and the forecasting gains hold across periods and training-window strategies?

## 2. Data

Inputs are described in `DATA.md`.

| | BD | PK |
|---|---|---|
| Series | `remittances_usd_mn`, US$ million, not seasonally adjusted | `remittances_usd_mn`, US$ million, original (not seasonally adjusted) |
| Primary span | Jul 2009 – Jun 2026 (204 months) | Jul 2005 – Jun 2026 (252 months) |
| Excluded from primary | Jul 2026 (single vintage) | Jul – Sep 2026 (first releases; Aug derived). Used in sensitivity S9 only |
| Transformation | natural log | natural log |

**Cross-country comparison window** (used only for sensitivity S10): Jul 2009 – Jun 2026, the span both countries share.

Raw levels are never compared across countries. Comparisons use percentage effects and within-country forecasting performance.

## 3. Eid regressors

Defined in `data/eid_exposure_monthly.csv`:
- **Dates:** each country's own national Eid dates (`data/eid_dates.csv`). Events with no source use the Umm al-Qura date and are flagged.
- **Primary regressors:** `fitr_w21` and `adha_w21`. Each is the share of the 21-day window ending on Eid day (inclusive) that falls in the month.
- **Sensitivity variants:**
  - 10-day and 30-day windows (`_w10`, `_w30`);
  - 21 days ending the day before Eid (`_w21_pre`);
  - Umm al-Qura dates (`_w21_uq`).

## 4. Model

RegARIMA on `log Y_t`:

```
log Y_t = β0 + β_F · Fitr_t + β_A · Adha_t + γ'Z_t + ε_t,   ε_t ~ SARIMA(p,d,q)(P,D,Q)_12
```

**Trend.** With differenced errors, the linear trend term is replaced by a drift. A drift is included only when d + D = 1; this is the default behaviour of `forecast::Arima` / `auto.arima`.

**Interventions.** `Z_t` holds the intervention regressors. They are chosen by the rule in §5.

**The two models in each comparison:**
- **Baseline:** `Z` only, with no Eid regressors.
- **Model with Eid regressors:** `Z` plus `Fitr` and `Adha`, with identical orders, training data and interventions.

**Order selection.** Orders are chosen with `auto.arima` on the baseline, given `Z`:
- `stepwise = FALSE`, `approximation = FALSE`;
- `max.p = 3`, `max.q = 3`, `max.P = 1`, `max.Q = 1`;
- `d` chosen by the KPSS test and `D` by the default seasonal test;
- information criterion: AICc.

Those orders are then applied to the model with Eid regressors.

**Software.** R with `forecast`, `sandwich` and `lmtest`. Outlier detection uses `scripts/lib_outliers.R`, an independent implementation of the Chen–Liu procedure with the same stages and defaults as `tsoutliers::tso`. It reproduces a `tso` 0.6-10 run made in RStudio exactly (6 of 6 outliers, same types, coefficients and t-statistics to 3 decimals; `scripts/check_outliers_vs_tsoutliers.R`). `tsoutliers` itself cannot be installed in the analysis environment.

## 5. Intervention rule (common to both models in a pair)

An intervention enters only if all three conditions hold:
1. **External reason.** It belongs to the candidate list below, which is fixed now with a dated reason for each entry.
2. **Support in the data.** It is detected on the **model with Eid regressors**, not on the baseline.
3. **Inside the training window.** At least 3 observations after its date lie inside the training window.

The selected set `Z` is then used in **both** models of the pair.

### Candidate list

| ID | Country | Window (calendar month) | External reason |
|---|---|---|---|
| B1 | BD | Jul 2019 | 2% cash incentive on remittances through formal channels takes effect (FY20 budget) |
| B2 | BD | Mar – Jul 2020 | COVID-19: lockdowns, migrant-job losses, then a shift to formal channels as informal (hundi) channels were disrupted |
| B3 | BD | Jan 2022 | Incentive raised from 2% to 2.5% |
| B4 | BD | Sep 2022 | Bankers' association (BAFEDA/ABB) caps the remittance exchange rate; the gap with the kerb market widens |
| B5 | BD | Aug – Oct 2024 | Change of government (5 Aug 2024) followed by a sharp rise in remittances through formal channels |
| P1 | PK | Oct 2008 – Jan 2009 | Global financial crisis shock to Gulf labour markets |
| P2 | PK | Apr – Jun 2009 | Pakistan Remittance Initiative launched (Apr 2009) |
| P3 | PK | Jul 2016 | Contraction of the Gulf labour market (Saudi construction-sector layoffs) |
| P4 | PK | Mar – Jul 2020 | COVID-19 (as B2) |
| P5 | PK | Sep 2022 | Gap between the interbank and open-market exchange rates widens; rate caps |
| P6 | PK | Sep 2023 | Crackdown on currency smuggling and the kerb market; exchange-company reforms |

### Detection and selection, at each forecast origin and for the full-sample fits

1. **Provisional fit.** Fit the model with Eid regressors using the airline error model, (0,1,1)(0,1,1)_12, as X-13 does for outlier identification.
2. **Test each candidate month.** For each month inside an eligible candidate window, add one regressor of each type and record its likelihood t-statistic from the Hessian:
   - additive outlier (AO);
   - temporary change (TC, decay 0.7);
   - level shift (LS).
3. **Critical value.** Use the same default as `tsoutliers`: `cval(n) = 3` for `n ≤ 50`, `4` for `n ≥ 450`, and linear in between (`3 + 0.0025·(n − 50)`), where `n` is the number of training observations.
4. **Forward selection.** Add the (month, type) with the largest |t| ≥ cval. Refit and repeat until no remaining candidate passes. Each window contributes at most 2 interventions.
5. **Choose orders.** Run `auto.arima` on the baseline with the selected `Z` (§4).

### Sensitivities for the intervention rule
- **S5:** no interventions at all.
- **S6:** fully automatic detection with no external-reason requirement. `detect_outliers()` (the tso-equivalent procedure: AO, TC, LS; airline errors; Eid regressors included; default cval), applied to both models.

**The Aug 2024 BD break** (candidate B5) is tested by this rule. It is reported as a limitation only if it is not detected.

## 6. RQ1: estimating the Eid effects

**Full-sample fit.** One fit per country over the primary span, with orders and interventions chosen by §4–5 on the full sample. Report:
- `β_F` and `β_A`;
- percentage effects `100·(exp(β) − 1)`;
- 95% confidence intervals from Hessian standard errors;
- p-values;
- residual diagnostics: Ljung–Box at lag 24 with fitdf equal to the number of ARMA parameters, a residual ACF plot, and a Jarque–Bera normality test;
- the intervention set selected.

**Cross-country test.** For each Eid, H0: β_BD = β_PK.
- **Primary:** `z = (β̂_BD − β̂_PK) / sqrt(se_BD² + se_PK²)`, using the full-span fits and treating the two country fits as independent.
- **Sensitivity S10:**
  - both fits re-estimated on the common window Jul 2009 – Jun 2026;
  - the variance of the difference adjusted for correlated shocks: `se_BD² + se_PK² − 2·ρ̂·se_BD·se_PK`, where ρ̂ is the contemporaneous correlation of the two models' innovations;
  - this is an approximation and is reported as one.
- **Interpretation rule:** a significant effect in one country and a non-significant one in the other is not evidence that the effects differ.

**Temporal stability.**
- Add `Fitr×Post` and `Adha×Post` with Post = 1 from Jul 2020 (start of FY21). This is the same split used in the BD thesis and follows the shift to formal channels during COVID.
- Report the Wald test of the two interaction terms.
- A change in the level of remittances (captured by the interventions) is kept separate from a change in the Eid effect (captured by the interactions).
- No other break date is searched for.

## 7. RQ2: forecasting value

### Design
- **Rolling-origin evaluation with an expanding training window.**
- **First origin:** Jun 2017, for both countries. BD then has 96 training months and PK 144. Both countries are therefore evaluated on the **same target months**, Jul 2017 – Jun 2026.
- **Last origin:** Jun 2026 − h.
- **At each origin:** select interventions (§5), then orders on the baseline (§4), then fit both models, then forecast h = 1, …, 12 months ahead.

### Horizons
- Focal (exploratory): h = 1 and 3.
- Supplementary: h = 6 and 12.

### Errors and loss
- **Primary errors are on the log scale:** `e = log y − log ŷ`. These are approximately percentage errors and are comparable across countries.
- **Level-scale errors are also reported,** using `exp(log ŷ)` as the point forecast. This is the median forecast; no bias adjustment is made.

### Metrics
- MAE and RMSE (log scale and level scale);
- MASE, scaled by the in-sample seasonal-naive MAE of each training window;
- MAPE (supplementary);
- mean error, to show bias;
- improvement % = `100·(Loss_base − Loss_Eid)/Loss_base`, where positive means the Eid regressors help.

### Inference

| Test | Role | Details |
|---|---|---|
| Clark–West | **Primary.** The models are nested. | Squared error on the log scale; one-sided; HAC (Newey–West) variance with `h − 1` lags. **Holm correction over the 4 primary tests** (BD and PK × h = 1 and 3) at α = 0.05. |
| Diebold–Mariano | Secondary | Absolute-error loss; Harvey–Leybourne–Newbold correction; two-sided; HAC with `h − 1` lags; reported without correction |
| 95% CI | Descriptive | Mean loss difference (squared and absolute), HAC variance |

All horizons are reported, not only the significant ones. If Clark–West and Diebold–Mariano disagree, this is read as the two tests asking different questions, not as one being right. Bias and the size of the loss differences are examined either way.

### Benchmarks
These are reported alongside the main comparison; they do not answer a research question.
- **Seasonal naive.**
- **SARIMA identified by ACF/PACF** (Box–Jenkins):
  - orders identified once, from the training data available at the first origin (to Jun 2017), using ACF/PACF plots, AICc and residual checks;
  - the identification is documented in a script before any forecast is made;
  - coefficients are re-estimated at every origin with those orders fixed.

No claim is made that RegARIMA is the best forecasting model.

## 8. Training-window and later-period analysis (secondary, within RQ2)

**Window strategies:**
- Expanding window, against rolling windows of 60 and 96 months.
- All three are compared on the same target months (Jul 2017 – Jun 2026).
- A 120-month rolling window is possible only from origin Jun 2019 for BD. It is therefore compared with the expanding window on targets from Jul 2019 onward, for both countries.

**Questions:**
1. Do rolling windows beat the expanding window?
2. Are errors smaller for targets from Jul 2020 onward than for targets before Jul 2020?
3. Does the gap grow after the selected interventions?
4. **Does the window strategy change how much the Eid regressors add?** This is the key question here. It is answered by comparing improvement % and the Clark–West statistics across strategies on the same targets.

Smaller errors in later periods are not read as evidence that recent data are better, because later periods may simply be easier to forecast. The stronger evidence is the comparison of strategies on the same target months.

## 9. Sensitivity analyses

| ID | Change | Purpose |
|---|---|---|
| S1 | Eid windows of 10 and 30 days | Exposure length |
| S2 | 21 days ending the day before Eid | Window position |
| S3 | Umm al-Qura dates | Local vs Umm al-Qura calendar |
| S4 | Fixed airline orders (0,1,1)(0,1,1)_12 at every origin | Order selection |
| S5 | No interventions | Intervention rule |
| S6 | Fully automatic detection (Chen–Liu), no external-reason requirement | Intervention rule |
| S7 | Rolling windows of 60, 96 and 120 months | Training window (§8) |
| S8 | Pre/post Jul 2020 interaction (§6) and split-period evaluation (§8) | Stability over time |
| S9 | PK span extended to Sep 2026 | Sample end |
| S10 | Common window Jul 2009 – Jun 2026, with the ρ̂-adjusted cross-country test | Cross-country comparability |

Sensitivity results are reported in full. They are not used to choose a "best" specification after the fact.

## 10. Order of work and reporting

**Stop points:**
1. Phase 1 (done): data and Eid dates.
2. This plan.
3. One confirmatory run.

**Order inside the run:**
- BD and PK are run with identical code.
- The PK results are produced by the same run and the specification is not changed after seeing them.
- If a coding error is found after the run, it is fixed and logged as a deviation. The before/after difference is reported.

**Results are reported in three parts:**
- **Observed:** numbers only.
- **Interpretation.**
- **Unresolved.**

**Paper structure:**
1. Introduction and literature review
2. Data and method
3. RQ1
4. RQ2
5. Robustness and training-window analysis
6. Discussion
7. Conclusion

---

## Status notes and deviations log

| Date | Note |
|---|---|
| 2026-11-03 | Exploratory runs on both countries were done before this design was fixed (Bangladesh: registered plan v1.1 and post hoc checks; Pakistan: in-sample Eid estimates and a paired airline SARIMA forecast comparison). Pakistan is therefore a replication of a Bangladesh-informed design whose results were seen before fixing it. This must be disclosed. |
| 2026-11-03 | Open decisions: local vs Umm al-Qura Eid dates; fixed airline orders vs per-origin selection on the baseline; common intervention rule for the forecasting pair; exposure definition. All are resolved in v1.0 (§3–5). |
| 2026-11-04 | Decisions taken before fixing the plan (from Sharof's answers of 4 Nov). (1) Eid dates: local national dates with a source per event; Umm al-Qura fallback flagged. (2) Window: 21 days ending on Eid day; "day before" is a sensitivity variant. (3) Sample: each country's full span is primary; the common window is a sensitivity check for the cross-country test. This reverses an earlier instruction to restrict all analysis to the common period. (4) Interventions: external reason plus support in the data, entered only once inside the training window; detection on the model with Eid regressors; the same interventions are applied to both models. (5) Orders re-selected on the baseline at each origin; fixed airline orders as sensitivity. (6) Holm correction over 4 Clark–West tests. (7) Wording: "with Eid regressors"; trend becomes drift under differencing. (8) The Aug 2024 BD break is tested, not assumed. |
| 2026-11-04 | Phase 1 delivered: Eid date table, `DATA.md`, exposure regressors. In-sample Umm al-Qura fallbacks: BD 2 of 36 events, PK 10 of 44. PK series extended to Sep 2026 from SBP bulletins and press figures (`DATA.md` §1a). |
| 2026-11-04 | v1.0 fixed. Choices made by Claude where the 4 Nov answers left details open (all listed here so they can be reviewed): PK primary end Jun 2026; the 3 caption-sourced BD Eid dates kept; first origin Jun 2017 for both countries, so they share target months; candidate intervention list B1–B5 and P1–P6; detection on the airline model with tsoutliers-style cval(n) and at most 2 interventions per window; minimum 3 post-event observations before an intervention can enter; log-scale loss as primary; ρ̂-adjusted variance for the common-window cross-country test; stability split at Jul 2020; ACF/PACF benchmark identified once on data to Jun 2017. Outlier detection is implemented in-house because `tsoutliers` cannot be installed. |
| 2026-11-04 | Outlier code validated against `tsoutliers::tso` 0.6-10 run by Sharof in RStudio (full primary spans, airline errors, Eid regressors). Exact match: BD 2017-09 AO, 2020-03 TC, 2020-06 LS, 2023-09 AO; PK 2008-10 AO, 2022-10 LS. These results were seen **after** the v1.0 commit (683f560) and do not change the plan. In particular, the PK Oct 2022 level shift lies outside candidate window P5 (Sep 2022); the candidate list is **not** widened because of it. That shift enters only in S6. |
