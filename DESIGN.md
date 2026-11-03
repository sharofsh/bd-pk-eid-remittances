# Study design (draft, not yet frozen)

Text below is the working design as drafted on 3 Nov 2026. Freeze it (date and commit) before running the confirmatory Pakistan analysis. Any later change goes in the deviations log at the end.

---

The cross-country differences in the effects of Islamic-calendar events on workers' remittances, and whether modelling those effects provides measurable forecasting value.

This is a focused study, not two separate papers.
1. Working title
Eid Effects in Monthly Workers' Remittances: Estimation and Forecasting Value in Bangladesh and Pakistan

An alternative with a slightly stronger research emphasis:

Islamic-Calendar Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan

I prefer the second title.
2. Research questions
RQ1 — Effect estimation

Are Eid al-Fitr and Eid al-Adha associated with changes in monthly workers' remittances in Bangladesh and Pakistan, and do the magnitude and direction of these effects differ between the countries?

RQ2 — Forecasting value

Does incorporating Eid-related regressors improve out-of-sample forecasts of monthly workers' remittances in Bangladesh and Pakistan?

Secondary investigation: Are the estimated effects and forecasting improvements stable across different periods and training-window strategies?

Two RQs are sufficient. Don't add a separate model-selection RQ.
3. Data and study population
Component	Bangladesh	Pakistan
Outcome	Monthly workers' remittances	Monthly workers' remittances
Frequency	Monthly	Monthly
Historical period	2009–2026, subject to availability	Available comparable period
Eid information	Historical local Eid dates	Historical local Eid dates
Transformation	Natural logarithm	Natural logarithm

Before analysis, document:
- Source and definition of remittance series.
- Currency and units.
- Whether figures are revised or seasonally adjusted.
- Missing observations and reporting changes.
- Historical Eid-date sources and verification.
Use each country's actual local Eid dates, not automatically the Saudi calendar. Public-holiday dates should not be mistaken for the actual religious dates.

Do not compare raw remittance levels across countries. Compare percentage effects and within-country forecasting performance.
4. RQ1: Estimation of Eid effects
Use regression with seasonal ARIMA errors (RegARIMA).

A general specification is:
\[
\begin{aligned}
\log(Y_t) ={}& \beta_0+\beta_1 Trend_t\\
&+\beta_2 Fitr_t+\beta_3 Adha_t\\
&+\boldsymbol{\gamma}'\mathbf{Z}_t+\varepsilon_t
\end{aligned}
\]

where:
- \(Y_t\): monthly workers' remittances.
- \(Fitr_t\): monthly Eid al-Fitr exposure.
- \(Adha_t\): monthly Eid al-Adha exposure.
- \(\mathbf{Z}_t\): justified intervention variables.
- \(\varepsilon_t\): seasonal ARIMA errors.
Eid exposure construction
Use a primary 21-day event window, with fractional monthly exposure.

For example, if an event window overlaps two calendar months, allocate exposure according to the number of event-window days falling in each month.

Estimate Fitr and Adha separately.

Report:
- Estimated coefficients.
- Percentage effects, calculated as \(100[\exp(\beta)-1]\).
- 95% confidence intervals.
- Statistical significance.
- Residual diagnostics.
Use 10-day and 30-day windows as sensitivity analyses.
Structural shocks and outliers
Explicitly investigate COVID-related disruptions and major country-specific structural changes.

Distinguish additive outliers, temporary changes and persistent level shifts.

Do not automatically classify every unusual observation as an outlier. A persistent change in remittance behaviour may be economically meaningful.
Cross-country effect comparison
This is essential.

Test whether:
\[
H_0:\beta_{Fitr,BD}=\beta_{Fitr,PK}
\]

and
\[
H_0:\beta_{Adha,BD}=\beta_{Adha,PK}
\]

Use a suitable pooled interaction specification or an equivalent direct test of coefficient differences, accounting for the separate country-specific error structures.

A significant coefficient in one country and a nonsignificant coefficient in the other does not establish that their effects differ.
5. RQ2: Does modelling Eid improve forecasting?
This is the main forecasting experiment.

Use one model family and construct a controlled pair:
Model A — Baseline RegARIMA

Trend, interventions and seasonal ARIMA errors. No Eid regressors.

Model B — Eid-aware RegARIMA

Exactly the same specification, with Eid al-Fitr and Eid al-Adha exposure regressors added.

Compare out-of-sample forecast errors


Keep the following identical within each pair:
- Training observations.
- ARIMA orders.
- Intervention/outlier treatment.
- Forecast origins.
- Forecast horizons.
- Estimation and forecasting procedures.
ARIMA orders should be selected using training data only. For each origin, select the orders using the baseline procedure and apply those orders to both members of the pair.

Outlier-treatment warning: This is a major potential source of bias. If the baseline model identifies an Eid-related peak as an additive outlier but the Eid-aware model does not, the comparison is no longer isolating the Eid contribution. Use a common intervention-selection procedure and investigate the results with and without automatic outlier detection.
Benchmarks
Keep seasonal naïve as a basic reference.

I would also retain one diagnostic SARIMA model developed using ACF/PACF as a supplementary forecasting benchmark. This addresses your interest in conventional Box–Jenkins identification without turning the paper into a large model competition.

For this benchmark:
1. Examine ACF/PACF using training observations only.
2. Identify plausible seasonal and nonseasonal orders.
3. Estimate candidate models.
4. Check AICc and residual diagnostics.
5. Evaluate its forecasts at the same origins as the RegARIMA models.
It is a benchmark, not a third central research question. Do not claim RegARIMA is the best forecasting model unless you actually conduct a sufficiently broad and fair model comparison.
6. Forecast evaluation protocol
Use rolling-origin evaluation with an expanding training window as the primary design.

At each forecast origin:
1. Fit the baseline model using available historical observations.
2. Select the ARIMA orders and intervention specification using training data only.
3. Fit the Eid-aware model using the same orders and intervention specification.
4. Generate forecasts from both models.
5. Calculate forecast errors.
6. Advance the origin and repeat.
Forecast horizons
Horizon	Role
1 month	Focal
3 months	Focal
6 months	Supplementary
12 months	Supplementary

Because your earlier analysis identified stronger gains at short horizons, describe h=1 and h=3 as exploratory focal horizons. Do not retrospectively call them pre-specified.
Metrics
- MAE
- RMSE
- MASE
- MAPE as a supplementary measure
Report relative improvement as well as absolute error. For example:
\[
Improvement(\%) =
100\frac{Loss_{base}-Loss_{Eid}}{Loss_{base}}
\]

Positive values indicate improvement from including Eid information.
Statistical testing
- Clark–West: primary inferential test for nested models under squared-error loss.
- Diebold–Mariano: secondary comparison using explicitly specified loss differentials, such as absolute errors.
- Confidence intervals for forecast-loss differences.
- HAC adjustments where required for serial dependence and overlapping multi-step forecasts.
Do not interpret 11 significant Clark–West results and zero significant DM results as proof that one test is correct and the other is wrong. They test different formulations of predictive performance. Investigate the loss functions, forecast biases and magnitude of improvements.

Correct for multiple testing across the genuinely designated primary comparisons. Report the full horizon results, not only significant ones.
7. Training-window sensitivity and later-period errors
I would definitely retain your observation that later evaluation windows appear to have lower errors.

But make it a secondary analysis within RQ2, rather than another research question.

Compare:
Strategy	Training observations
Expanding window	All available observations since the beginning
Rolling 96-month window	Most recent 96 observations

Evaluate both strategies on identical target months.

Use the same model pair and forecast horizons.

Investigate:
1. Whether rolling windows outperform expanding windows.
2. Whether forecast errors decline in later evaluation periods.
3. Whether the difference becomes larger following structural changes.
4. Whether Eid-related forecasting gains depend on the training-window strategy.
For sensitivity, you can examine rolling windows of 60 and 120 months, if the data permit.

Important distinction: Lower forecast errors in later periods do not necessarily mean recent training data are superior. Later periods might simply be easier to predict. The expanding-versus-rolling comparison on identical target months is the stronger evidence.

Also, distinguish two questions:
- Does the training-window strategy change overall forecast accuracy?
- Does the training-window strategy change the incremental benefit of Eid regressors?
The second is particularly interesting for your paper.
8. Robustness analysis
Keep the robustness analysis focused.
Robustness check	Purpose
Eid windows: 10, 21 and 30 days	Exposure definition
With and without automatic outlier detection	Intervention sensitivity
Alternative plausible intervention specifications	Structural-shock sensitivity
Rolling windows: 60, 96 and 120 months	Training-window sensitivity
Pre-/post-structural-change estimates	Temporal stability
Alternative forecast horizons	Horizon dependence

For temporal stability, test changes in the Eid coefficients directly using interaction terms or a suitable coefficient-stability procedure.

Do not confuse a change in the average remittance level with a change in the Eid effect.

For the historical split, avoid choosing a breakpoint merely because it produces the most interesting result. Use an economically justified date and, where appropriate, supplement it with formal break analysis.
9. Bangladesh–Pakistan comparative analysis
Apply the same conceptual methodology to both countries, but allow country-specific ARIMA orders and intervention dates.

The comparison should answer:
Question	Evidence
Are Eid effects present in both countries?	Coefficients and confidence intervals
Do effect magnitudes differ?	Direct country-interaction tests
Does Eid improve forecasting in both?	Paired forecast-loss differences
Does recent training data help?	Expanding vs rolling comparison
Are findings stable?	Window and intervention sensitivity

Do not force identical model parameters on both countries. Comparability of the research procedure is more important than identical numerical specifications.

Pakistan is an independent replication setting only to the extent that you do not use its results to keep changing the methodology until the desired result appears. Freeze the primary specification before examining its confirmatory results.
10. Final paper structure
One paper, two countries, two research questions
1. Introduction and literature review
   
   Remittance forecasting, moving holidays, Islamic-calendar effects and research gap.
2. Data and methodology
   
   Data sources, Eid exposure construction, RegARIMA, interventions and forecasting protocol.
3. RQ1: Eid effect estimation
   
   Country-specific estimates, cross-country coefficient comparisons and temporal stability.
4. RQ2: Forecasting value
   
   Paired forecasts, benchmarks, forecast-loss comparisons and statistical tests.
5. Robustness and training-window analysis
   
   Alternative event windows, interventions and expanding-versus-rolling evaluation.
6. Discussion
   
   Explain similarities and differences between Bangladesh and Pakistan without unsupported causal claims.
7. Conclusion
   
   Implications for remittance forecasting and the treatment of moving-calendar effects.

---

## Status notes and deviations log

| Date | Note |
|---|---|
| 2026-11-03 | Exploratory runs on both countries were done before this design was frozen (Bangladesh: registered plan v1.1 and post hoc checks; Pakistan: in-sample Eid estimates and a paired airline SARIMA forecast comparison). Pakistan is therefore a replication of a Bangladesh-informed design whose results were seen before freezing. This must be disclosed. |
| 2026-11-03 | Open decisions: local vs Umm al-Qura Eid dates; fixed airline orders vs per-origin selection on the baseline; common intervention rule for the forecasting pair; exposure definition (share of the event window falling in each month, as used so far). |
| 2026-11-03 | Wording to fix before freezing: replace "Eid-aware" with "with Eid regressors"; with differenced ARIMA errors the linear trend term becomes a drift. |
| 2026-11-04 | Decisions taken before freezing (from Sharof's answers of 4 Nov). (1) Eid dates: local national dates with a source per event; where none is found, Umm al-Qura is used and the row is flagged (`data/eid_dates.csv`). (2) Window: 21 days ending on Eid day, as in all earlier BD results; "ending the day before Eid" is a sensitivity variant. (3) Sample: each country's full span is primary (BD Jul 2009 – Jun 2026; PK Jul 2005 – Dec 2024). The common window (Jul 2009 – Dec 2024) is used only as a sensitivity check for the cross-country coefficient test. This reverses an earlier instruction to restrict all analysis to the common period. (4) Interventions: an event is included only if it has both an external reason and support in the data, and only once its date is inside the training window. Automatic outlier detection runs on the model with Eid regressors (not the baseline), and the resulting interventions are applied to both models in the pair. (5) ARIMA orders are re-selected on the baseline at each origin; fixed airline orders are a sensitivity check. (6) Holm correction over the 4 primary Clark–West tests (BD, PK × h = 1, 3). (7) Wording fixes listed on 3 Nov are accepted. (8) The Aug 2024 BD break is tested with the full BD sample; it is reported as a limitation only if it is not detectable. |
| 2026-11-04 | Phase 1 delivered: Eid date table, data documentation (DATA.md), exposure regressors. In-sample Umm al-Qura fallbacks: BD 2 of 36 events, PK 10 of 40 (mostly 2005–2009). The design text above has not yet been edited to reflect the 4 Nov decisions; that is part of freezing (Phase 2). |
| 2026-11-04 | PK series extended to Sep 2026 from SBP bulletins and press figures (DATA.md §1a); reconciles with SBP cumulative totals. Recommended PK primary end: Jun 2026 (same as BD), with Jul–Sep 2026 as sensitivity only. To be confirmed at freezing. With this extension, the common window for the cross-country sensitivity check becomes Jul 2009 – Jun 2026. |
