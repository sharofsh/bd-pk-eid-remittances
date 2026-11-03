# Phase 3 confirmatory run: results

Run date: 4 Nov 2026. Plan: `DESIGN.md` v1.0 (pre-specified, date-stamped, commit 683f560, merged as PR #2).
One run per configuration, BD and PK with identical code. Two code defects were found during the run and fixed (deviations log, 4 Nov). Neither changes any number outside S6 BD; see §6.

Each section is split into **Observed** (numbers only), **Interpretation**, and **Unresolved**.

Files: `rq1_*.csv`, `eval_*.csv`, `forecasts/<config>_<cc>.csv` (per origin: orders, interventions, Eid coefficients), `forecast_run_log.txt`.

---

## 1. RQ1: Eid effects (full-sample RegARIMA, log remittances)

### Observed

| | Orders (chosen on baseline) | Interventions | Fitr: % [95% CI] | Adha: % [95% CI] |
|---|---|---|---|---|
| BD, Jul 2009 – Jun 2026 (n = 204) | (0,1,1)(0,0,1) | LS Jun 2020 [B2] | 13.2 [6.9, 19.9] | 16.8 [10.2, 23.8] |
| PK, Jul 2005 – Jun 2026 (n = 252) | (0,1,1)(1,0,0) + drift | LS Jun 2020 [P4] | 13.9 [8.3, 19.7] | 12.8 [7.2, 18.7] |

The percentage is the effect of a month that contains the full 21-day pre-Eid window (exposure = 1), computed as 100·(e^β − 1).

- **Cross-country difference** (BD − PK, on the β scale):
  - Fitr: −0.006 (SE 0.039), p = 0.88.
  - Adha: +0.035 (SE 0.039), p = 0.37.
- **S10, common window Jul 2009 – Jun 2026**, with the ρ̂-adjusted test (ρ̂ = 0.475):
  - Fitr p = 0.58; Adha p = 0.55.
  - PK effects on this window: Fitr 15.0%, Adha 14.8%.
- **S8 stability** (interaction with Post = Jul 2020), Wald test on the 2 interaction terms:
  - BD p = 0.79. Interaction terms: Fitr +0.024 (SE 0.060), Adha +0.037 (SE 0.059).
  - PK p = 0.99. Interaction terms: −0.007 (SE 0.056), −0.006 (SE 0.054).
- **Diagnostics:**
  - BD: Ljung–Box(24) p = 0.073; Jarque–Bera p = 0.16.
  - PK: Ljung–Box(24) p = 0.0001, with residual ACF spikes at lags 13, 14 and 35; Jarque–Bera p = 0.09.
- **Candidate interventions not selected:** BD B1, B3, B4 and B5 (Aug 2024); PK P1–P3, P5 and P6. B5 was never selected at any forecast origin either.

**Sensitivities (Fitr % / Adha %):**

| Spec | BD | PK |
|---|---|---|
| Primary (w21) | 13.2 / 16.8 | 13.9 / 12.8 |
| S1 w10 | 7.0 / 11.7 | 8.3 / 7.8 |
| S1 w30 | 19.0 / 20.9 | 19.6 / 16.9 |
| S2 window ends day before Eid | 14.1 / 17.6 | 14.9 / 13.5 |
| S3 Umm al-Qura dates | 13.9 / 17.7 | 14.5 / 13.5 |
| S4 airline orders | 12.8 / 18.7 | 11.0 / 11.9 |
| S5 no interventions | 10.9 / 19.1 | 12.9 / 13.0 |
| S6 automatic outliers | 12.9 / 15.8 | 11.9 / 12.4 |
| S9 PK to Sep 2026 | — | 13.9 / 12.8 |

Every one of these effects has a 95% CI that excludes 0.

### Interpretation
- A full-window Eid month raises remittances by roughly 13–17% in both countries, for both Eids.
- The data give no evidence that the two countries differ: the point differences are under 4 log points, and the SEs are about 4 log points.
  - "Not different" here means *not detected*. The minimum detectable difference at 80% power is about 2.8 × 0.039 ≈ 0.11, i.e. 11 log points. Differences smaller than that cannot be ruled out.
- No change after Jul 2020 is detected. The post-2020 interaction SEs (≈0.06) are wide, however, so a change of ±10 log points cannot be excluded.
- The size of the effect scales with window length (w10 < w21 < w30). The window measures *how* exposure is spread across months, so coefficients from different windows are not comparable as "the" Eid effect. The w21 primary is a modelling choice, not an estimate of the true pre-Eid sending period.
- Local vs Umm al-Qura dates (S3) and pre-Eid vs on-Eid window end (S2) change the estimates by under 1 percentage point.

### Unresolved
- **PK residual autocorrelation** at lags 13/14/35. The Eid SEs for PK may be understated, so the cross-country test may be anti-conservative, although it already fails to reject. A plausible cause is a moving-holiday echo (Eid moving across adjacent months year to year), but this has not been tested.
- **B5 not detected.** The Aug 2024 BD break (the regime change and the flow into the formal channel after it) is not supported by the data under the pre-specified rule. Per the plan, this is reported as a limitation.
- **BD Sep 2017 dip and PK Oct 2022 shift.** Both show up only under automatic detection (S6). The PK Oct 2022 shift lies outside candidate window P5, and the window was not widened. S6 moves the estimates by at most 2 percentage points.

---

## 2. RQ2: Do Eid regressors improve forecasts? (primary: expanding window, targets Jul 2017 – Jun 2026)

### Observed

**Confirmatory tests** (Clark–West, one-sided, Holm-adjusted over 4 tests):

| | n | CW t | raw p | Holm p | Reject at 5% |
|---|---|---|---|---|---|
| BD h = 1 | 108 | 3.00 | 0.0014 | 0.0041 | yes |
| BD h = 3 | 106 | 2.58 | 0.0049 | 0.0050 | yes |
| PK h = 1 | 108 | 2.81 | 0.0025 | 0.0050 | yes |
| PK h = 3 | 106 | 3.10 | 0.0010 | 0.0039 | yes |

**Secondary tests** (Diebold–Mariano, absolute loss, HLN correction, two-sided, uncorrected):
- BD h1 p = 0.022; BD h3 p = 0.10.
- PK h1 p = 0.11; PK h3 p = 0.08.

**Size of the gain** (log scale):
- RMSE improvement, BD: 7.0% (h1), 3.9% (h3), 2.4% (h6), 0.3% (h12).
- RMSE improvement, PK: 6.1%, 5.8%, 4.0%, 1.3%.
- 95% HAC intervals for ΔMSE (baseline − Eid) include 0 at h1 and h3 in both countries (BD h1: [−0.0001, 0.0052]).
- The ΔMAE interval excludes 0 only for BD h1.

**Clark–West at all horizons:**
- p < 0.05 for every h in PK.
- p < 0.05 for every h in BD except h = 12 (p = 0.12).

**Accuracy and benchmarks, h = 1:**

| | RMSE log | MAE log | MASE | ME log | RMSE (US$ m) | MAPE % |
|---|---|---|---|---|---|---|
| BD baseline | 0.138 | 0.107 | 0.83 | +0.015 | 261 | 10.5 |
| BD Eid | 0.128 | 0.098 | 0.76 | +0.015 | 237 | 9.7 |
| BD Box–Jenkins (0,1,1)(1,1,1) | 0.137 | 0.106 | 0.82 | +0.012 | 264 | 10.5 |
| BD seasonal naive | 0.220 | 0.183 | 1.41 | +0.113 | 413 | 16.8 |
| PK baseline | 0.104 | 0.082 | 0.57 | −0.005 | 249 | 8.2 |
| PK Eid | 0.098 | 0.077 | 0.53 | −0.003 | 225 | 7.7 |
| PK Box–Jenkins | 0.102 | 0.080 | 0.55 | −0.008 | 240 | 8.1 |
| PK seasonal naive | 0.182 | 0.148 | 1.02 | +0.085 | 439 | 13.9 |

- **Bias.** BD mean error is positive (the models underforecast) and grows with horizon: +0.015 at h1, +0.028 at h3, +0.052 at h6, +0.085 at h12. PK mean error is about 0 at every horizon.
- **Eid model vs Box–Jenkins.** The Eid model has the lowest RMSE and MAE of the four models at h1, h3 and h6 in both countries. The Box–Jenkins benchmark beats the baseline in PK at h = 1, 3, 6 and 12. In BD it matches the baseline at h1 and is worse at h = 3, 6 and 12.

**Where the gain comes from** *(post hoc decomposition, not pre-specified)*:
- At h1, splitting by whether the target month has any Eid exposure:

  | | Eid months | Non-Eid months |
  |---|---|---|
  | BD | 30 months, RMSE improvement 15.3% | 78 months, 1.7% |
  | PK | 30 months, 11.6% | 78 months, 1.4% |

- The five targets with the largest loss reductions account for 85% (BD) and 92% (PK) of the total reduction in squared error.
- The largest single target in both countries is Jul 2020: Eid al-Adha on 1 Aug 2020, so the 21-day window falls almost entirely in July, during the COVID-era shift to formal channels.
- Excluding Jul 2020, the h1 improvement is 5.0% (BD) and 4.9% (PK).

### Interpretation
- **RQ2 is answered "yes" under the pre-specified test.** The Clark–West null of equal population MSE is rejected at h = 1 and 3 in both countries after the Holm correction.
- **The tests differ in what they show.** Clark–West tests whether the Eid coefficients add predictive content. Diebold–Mariano tests whether the *estimated* model's realised loss is smaller in this sample of about 108 targets. The CW rejections combined with mostly non-significant DM results and ΔMSE intervals that cover 0 mean: the Eid terms carry real signal, but the realised accuracy gain over 9 years is modest (about 4–7% RMSE at h ≤ 3) and not precisely estimated. The plan calls for reading the two tests as asking different questions, and the result is reported that way.
- **The gain is where it should be.** Almost all of it falls in months that have Eid exposure, and almost none in other months. That supports the mechanism and argues against the improvement being a side-effect of different order selection or interventions (both models share these). It also means the evidence rests on about 18 Eid events per country, and one COVID-period month carries a large share.
- **The gain fades with horizon,** reaching about 0 in BD at h = 12. A likely reason is that at long horizons, level and trend error (the BD underforecast) dominate the Eid-month errors.
- **The models beat the textbook benchmarks.** The Eid model beats both the seasonal naive and a fixed Box–Jenkins SARIMA at short horizons. The *baseline* with per-origin auto.arima orders does not reliably beat the fixed Box–Jenkins model in PK.

### Unresolved
- **Persistent BD underforecast** (positive ME growing with horizon). This reflects the post-2020 upward trend and the post-Aug-2024 surge that the models do not capture, since B5 was not selected. This is a limitation of the baseline, not of the Eid terms, but it inflates level-scale errors.
- **Sensitivity to Jul 2020.** No pre-specified robustness check covers the leverage of single Eid events. The without-Jul-2020 figures above are post hoc.

---

## 3. Training-window and later-period analysis (§8; S7, S8)

### Observed

**Eid gain by window strategy** (same target months; RMSE improvement % / CW t):

| | Expanding | Rolling 60 | Rolling 96 | Rolling 120 (targets ≥ Jul 2019) | Expanding (targets ≥ Jul 2019) |
|---|---|---|---|---|---|
| BD h1 | 7.0 / 3.00 | 6.3 / 2.91 | 6.2 / 2.72 | 7.7 / 2.62 | 6.7 / 2.50 |
| BD h3 | 3.9 / 2.58 | 3.6 / 2.54 | 1.6 / 2.30 | 0.3 / 1.38 | 3.7 / 2.29 |
| PK h1 | 6.1 / 2.81 | 3.4 / 2.28 | 6.7 / 2.41 | 2.0 / 1.55 | 4.3 / 2.16 |
| PK h3 | 5.8 / 3.10 | 3.0 / 1.99 | 3.9 / 2.53 | 2.9 / 1.96 | 4.8 / 2.49 |

**Baseline RMSE (log) by window strategy:**
- h1: BD expanding 0.138, rolling 60 0.145, rolling 96 0.142. PK 0.104, 0.116, 0.115.
- h3: BD 0.164, 0.184, 0.173. PK 0.119, 0.132, 0.130.
- Rolling 120 vs expanding on the same targets (≥ Jul 2019): BD h1 0.146 vs 0.142; PK h1 0.108 vs 0.102.

**Split by period** (primary; targets before vs from Jul 2020; RMSE log, baseline → Eid):

| | Pre (36 / 34 targets) | Post (72 targets) |
|---|---|---|
| BD h1 | 0.144 → 0.139 (3.6%, CW t 1.88) | 0.134 → 0.122 (9.0%, CW t 2.52) |
| BD h3 | 0.157 → 0.161 (−2.7%, t 0.04) | 0.168 → 0.156 (6.8%, t 2.65) |
| PK h1 | 0.115 → 0.115 (−0.3%, t 0.61) | 0.098 → 0.088 (10.7%, t 3.27) |
| PK h3 | 0.110 → 0.110 (−0.4%, t 0.56) | 0.124 → 0.113 (8.2%, t 3.15) |

**Interventions selected at forecast origins:**
- Expanding window: LS Jun 2020 from origin Sep 2020 (BD) and Oct 2020 (PK) onward. Before that, briefly TC Mar 2020 (BD) and TC Jun 2020 (PK). For PK, AO Oct 2008 and AO Jul 2016 at the first 4 origins.
- Rolling windows also select BD LS Mar 2020 and PK LS Sep 2022 for stretches of origins (2021–24).

### Interpretation
1. **Rolling vs expanding.** Rolling windows do **not** beat the expanding window. Baseline errors are higher under every rolling length, in both countries, at h1 and h3.
2. **Later vs earlier errors.** Errors are smaller after Jul 2020 at h1 in both countries, but larger at h3. Per the plan, this is not read as evidence that recent data are better.
3. **Gap after interventions.** The Eid gain is almost entirely a post-Jul-2020 phenomenon in both countries. Before Jul 2020 (3 years, about 6 Eid events) the gain is about 0. Because LS Jun 2020 enters at origins Sep/Oct 2020, "after the selected intervention" and "post-Jul 2020" nearly coincide, and the two cannot be separated.
4. **Key question: does the window strategy change the Eid gain?**
   - The Eid gain survives every window strategy at h1 in BD.
   - It is smaller under rolling 60 for PK, and smallest under rolling 120 (BD h3 0.3%, PK h1 2.0%).
   - The expanding window gives the largest or near-largest gain in 3 of 4 country-horizon cells.
   - Reading: longer histories help estimate the Eid coefficients. This is consistent with the Eid effect being identified from Eid moving through the calendar, which needs many years.
5. **Coefficients are stable but forecast gains are not.** The full-sample Eid coefficients show no change after Jul 2020 (§1), yet the forecast gain appears only after Jul 2020. No explanation is established. Two candidates, neither tested here:
   - **Sampling noise.** The pre-period has about 6 Eid events and wide error bands.
   - **Error variance.** The baseline's Eid-month errors may be larger after 2020, leaving more for the Eid terms to fix. This could happen if its seasonal terms misplace the Eid peak more often as the Eids moved from Jun–Sep (2017–20) into Mar–Jul (2021–26).

### Unresolved
- The pre-2020 window has about 6 Eid events per country, so a zero gain there is weakly informative.
- Why the gain is concentrated after Jul 2020 (point 5). Testing it would need a longer evaluation period or a simulation in which Eid timing is varied.

---

## 4. Sensitivities on forecasting (S1–S6, S9; Clark–West t, RMSE improvement %)

| Spec | BD h1 | BD h3 | PK h1 | PK h3 |
|---|---|---|---|---|
| Primary | 3.00, 7.0 | 2.58, 3.9 | 2.81, 6.1 | 3.10, 5.8 |
| S1 w10 | 2.65, 4.5 | 2.08, 3.2 | 1.58, 1.8 | 1.69, 1.6 |
| S1 w30 | 3.13, 8.1 | 1.79, 0.2 | 3.59, 10.6 | 3.45, 8.9 |
| S2 window ends day before Eid | 2.95, 7.1 | 1.90, 0.6 | 3.00, 7.2 | 3.27, 6.7 |
| S3 Umm al-Qura dates | 2.88, 6.8 | 2.01, 0.9 | 3.01, 7.2 | 3.26, 6.7 |
| S4 airline orders | 3.28, 9.3 | 2.91, 3.7 | 2.20, 1.9 | 2.03, −0.4 |
| S5 no interventions | 2.93, 6.3 | 1.95, 2.6 | 2.73, 5.7 | 3.27, 6.2 |
| S6 automatic outliers | 2.71, 4.3 | 1.39, 0.3 | 2.87, 6.2 | 3.04, 5.3 |
| S9 PK to Sep 2026 (111 / 109 targets) | — | — | 2.80, 6.1 | 3.11, 5.8 |

**Observed** (uncorrected one-sided Clark–West, which is the convention for sensitivities):
- At h1, CW t > 1.645 in every sensitivity except PK S1 w10 (t = 1.58, p = 0.057).
- At h3, the exceptions are BD S6 (t = 1.39) and PK S1 w10 (1.69, p = 0.045; borderline).
- S6 BD selects a median of 6 automatic outliers per origin, ranging from 1 to 27. The 27 occur at origin Aug 2020, right after the COVID shock.
- S6 PK selects a median of 2 per origin, ranging from 0 to 6.

**Interpretation:**
- **The h1 result is robust** to dates, window position, orders, the intervention rule and sample end.
- **The h3 result is weaker.** BD h3 improvement falls to under 1% under S1 w30, S2, S3 and S6, even though CW t stays above 1.645 in all but S6. The BD h3 gain is the most fragile of the 4 confirmatory cells.
- **The w10 window** gives a clearly weaker gain for PK. A 10-day window seems too short to capture the PK pre-Eid sending pattern.
- **Fixed airline orders** (S4) help BD but almost remove the PK h3 gain.
- **S6 is fragile.** Fully automatic detection is unstable at short series ends after large shocks: 27 outliers at one BD origin. This supports the pre-specified rule of requiring an external reason.

**Unresolved:** none beyond §2–3. These sensitivities were not used to choose a specification.

---

## 5. Limitations to state in the paper
1. **Prior exploratory runs.** Exploratory runs on both countries preceded the plan. PK is a replication of a BD-informed design whose results were seen in exploration. The focal horizons h = 1 and 3 were also chosen after exploration.
2. **B5 (Aug 2024 BD break) not detected** by the pre-specified rule, in the full sample or at any origin. The BD underforecast at longer horizons is consistent with an unmodelled post-Aug-2024 level change.
3. **PK residual autocorrelation** at lags 13, 14 and 35. The PK Eid SEs may be understated.
4. **Outliers outside the candidate list.** The BD Sep 2017 AO (post-Eid dip) and the PK Oct 2022 LS are found by automatic detection only. P5 was not widened to include Oct 2022.
5. **Eid date quality.** Umm al-Qura fallbacks were used for BD 2 of 36 and PK 10 of 44 in-sample events, and 3 BD dates come from photo captions. S3 shows the estimates are insensitive to the date source (under 1 percentage point).
6. **PK vintage break.** PK data from Jan 2025 are taken from SBP bulletins and press figures (`DATA.md` §1a). Aug 2026 is derived from other figures.
7. **Narrow evidence base.** The forecasting gain rests on about 18 Eid events per evaluation period and is concentrated in a handful of months, notably Jul 2020.
8. **In-house outlier code.** `tsoutliers` could not be installed in this environment. The in-house reimplementation matches `tso` exactly on the full-sample check (6 of 6 outliers) but has not been validated at every forecast origin.

## 6. Deviations during the run
- **Long cache filenames** (code defect, fixed). In S6 BD, origin Aug 2020 selected 27 automatic outliers. The resulting cache filename exceeded the 255-byte limit, and the origin was dropped by an R error. The run log reported "0 failed origins" because errors were not counted.
  - Fix: hash long cache keys, and count error-dropped origins as failures.
  - S6 BD was rerun; that origin now has a forecast.
  - Before → after for S6 BD (107 → 108 origins; "before" recomputed by dropping that origin): h1 CW t 2.72 → 2.71, RMSE improvement 4.4% → 4.3%; h3 1.42 → 1.39, 0.4% → 0.3%. No other configuration lost rows: every other file has 1230 / 942 / 1266 rows as expected.
- **Cache consistency.** The cache (`results/cache/`, not committed) was written only after the last edit to `lib_model.R` / `lib_outliers.R` (01:15). Every cached selection therefore comes from the final code.
