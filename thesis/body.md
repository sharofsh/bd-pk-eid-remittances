# Chapter 1`<w:r><w:br/></w:r>`{=openxml}Introduction

## 1.1 Background

Workers' remittances are one of the largest sources of foreign exchange for Bangladesh and Pakistan. Each country now receives more than US\$30 billion a year through formal channels (Bangladesh Bank; State Bank of Pakistan). Personal remittances were 6.1% of Bangladesh's GDP in 2024 (World Bank, 2026). Because remittances finance a large part of import payments and support foreign-exchange reserves, central banks and finance ministries need reliable short-term forecasts of monthly inflows.

Monthly remittances to both countries rise sharply before the two Eid festivals, Eid al-Fitr and Eid al-Adha. Migrants send money to cover festival spending, gifts, zakat and, for Eid al-Adha, the sacrificial animal. Bangladesh's record monthly inflow of March 2025 came in the month of Eid al-Fitr, and the Pakistani press regularly attributes spring surges to Ramadan and Eid (Business Recorder, 2024; The Business Standard, 2025).

The two Eids follow the lunar Hijri calendar. The Hijri year is about 11 days shorter than the Gregorian year, so each Eid falls about 11 days earlier every year and passes through every Gregorian month over roughly 33 years. A forecasting model that captures seasonality by Gregorian month, such as a seasonal ARIMA model, cannot follow a festival that changes month from year to year.

## 1.2 Problem Statement and Motivation

Standard forecasting models for monthly remittances treat seasonality as a fixed pattern by Gregorian month. When an Eid moves from one month to the previous one, such a model attributes the resulting jump to noise or to a change in trend. This has two consequences. First, the size of the Eid effect is not measured, even though press reports suggest it is large. Second, forecasts for Eid months are systematically too low, and forecasts for the months the Eid has left are too high.

Statistical agencies handle moving holidays such as Easter with regression variables inside a regression model with ARIMA errors, known as RegARIMA (Bell & Hillmer, 1983; Findley et al., 1998). Similar methods have been applied to Islamic holidays in Tunisia, Turkey and Pakistan (Grun Rehomme & Ben Rejeb, 2008; Aruoba & Alper, 2004; Riazuddin & Khan, 2005). However, the literature reviewed in Chapter 2 found no study that estimates Eid effects on Bangladesh's remittances, and none that tests whether Eid regressors improve remittance forecasts. This study fills that gap, with Bangladesh as the main case and Pakistan, a similar remittance-dependent economy, as the comparison.

## 1.3 Research Questions and Objectives

The study asks two research questions.

**RQ1 (effect estimation).**

- Are Eid al-Fitr and Eid al-Adha associated with changes in monthly workers' remittances in Bangladesh and Pakistan?

- Do the size and direction of these effects differ between the two countries?

**RQ2 (forecasting value).**

- Do Eid regressors improve out-of-sample forecasts of monthly workers' remittances in each country?

**Objectives.** The objectives are to:

- construct monthly Eid regressors for each country from its own national Eid dates;

- estimate the effects of Eid al-Fitr and Eid al-Adha on log remittances with a regression model with SARIMA errors (RegARIMA);

- test whether the Eid effects differ between Bangladesh and Pakistan;

- compare out-of-sample forecasts from a baseline model and the same model with Eid regressors, at horizons of 1 to 12 months; and

- compare both models with a seasonal naive forecast and a Box–Jenkins SARIMA model.

## 1.4 Hypotheses

The research questions translate into the following null hypotheses, each tested against the stated alternative.

- **H1 (Eid effects).** For each country and each Eid, H₀: β = 0 against H₁: β ≠ 0, where β is the coefficient of the Eid regressor in the RegARIMA model.

- **H2 (cross-country difference).** For each Eid, H₀: β_BD = β_PK against H₁: β_BD ≠ β_PK.

- **H3 (forecasting value).** For each country and horizon, H₀: the Eid regressors add no predictive content, so the baseline and the model with Eid regressors have equal expected squared forecast error, against the one-sided alternative that the model with Eid regressors has lower expected squared forecast error.

## 1.5 Significance of the Study

The study contributes in three ways. First, it gives the first estimates, to our knowledge, of separate Eid al-Fitr and Eid al-Adha effects on Bangladesh's monthly remittances. Second, it tests formally, with tests designed for nested models, whether Eid regressors improve out-of-sample forecasts; previous remittance forecasting studies for Bangladesh compared models on in-sample fit or raw error measures only. Third, it compares the Eid effects between two large remittance recipients with similar festival calendars.

The results have practical value for Bangladesh Bank and the State Bank of Pakistan. The Eid regressors can be added to an existing ARIMA forecasting model at almost no cost, because Eid dates are known years ahead.

## 1.6 Organization of the Thesis

Chapter 2 reviews the literature on remittances, Islamic-calendar effects, moving-holiday models, remittance forecasting and forecast evaluation, and states the research gap. Chapter 3 describes the data, the Eid regressors, the RegARIMA model, the intervention rule and the forecast evaluation design. Chapter 4 presents descriptive statistics, the estimated Eid effects and the forecast comparison, and discusses them against previous studies. Chapter 5 summarises the findings, their practical implications, the limitations of the study and directions for future research. The appendices give the data dictionary, the Eid dates, the full forecast test results, residual diagnostics and the code.

# Chapter 2`<w:r><w:br/></w:r>`{=openxml}Literature Review

## 2.1 Introduction

This chapter reviews the literature on remittances in Bangladesh and Pakistan, why remittances rise before festivals, Islamic-calendar effects, and the methods used to model and forecast them, and ends with the research gap (Section 2.6).

## 2.2 Remittances in Bangladesh and Pakistan

Remittances are a major source of foreign exchange for both countries, so short-term forecasts of them matter for reserve and exchange-rate management. In Bangladesh, personal remittances were 6.1% of GDP in 2024, against a long-run peak of 10.6% in 2012 (World Bank, 2026). Hundi, an informal and illegal transfer channel, carries a substantial further share that recorded data miss (Farabi et al., 2025).

Recorded remittances in both countries respond to policy as well as to migrants' incomes. Three kinds of event recur.

- **Incentives for formal channels.** Bangladesh introduced a 2% cash incentive on remittances received through formal channels in July 2019, raised to 2.5% in January 2022. Using interrupted time-series analysis, Farabi et al. (2025) estimate that the incentive caused an immediate, sustained 6.68% rise in inflows, with a further 0.25% each month. Pakistan launched the Pakistan Remittance Initiative in early 2009 to move transfers into formal channels (Shabbir, 2012).

- **COVID-19.** Recorded remittances fell in early 2020, then rose. Using monthly data for 52 countries, Kpodar et al. (2023) find that a shift from informal to formal channels, caused by travel restrictions, contributed to the surge in formal remittances. The World Bank reached the same conclusion for South Asia and warned that incentives in Bangladesh and Pakistan could make part of the increase more apparent than real (Ratha et al., 2020).

- **Exchange-market reforms.** The State Bank of Pakistan credits reforms of exchange companies, under the 2023–24 IMF Stand-By Arrangement, with improving Pakistan's external position in FY24 (State Bank of Pakistan, 2024). In Bangladesh, record formal inflows followed the change of government in August 2024; so far this has been documented only in the press, which attributes it to a fall in hundi activity (The Business Standard, 2025).

These events matter for modelling because they shift the level of the recorded series. A model that ignores them can mistake a policy shift for a festival effect, or forecast from the wrong level.

## 2.3 Theoretical Background: Why Remittances Rise Before Festivals

The migration literature explains remittances mainly as support for the family at home, which predicts that transfers rise when household spending needs peak. Lucas and Stark (1985) set out three motives: altruism towards the family; self-interest, for example protecting an inheritance or assets at home; and an implicit contract in which migrant and family insure each other. Stark and Lucas (1988) describe remittances as part of a longer-term family arrangement covering education, migration costs and support in bad times.

The two Eids are the largest spending occasions of the year in both countries: new clothes, gifts, travel and, for Eid al-Adha, the sacrificial animal. Ramadan also brings zakat and other religious giving. Under the altruism and family-contract motives, migrants should send more money in the weeks before each Eid. The financial press reports this pattern regularly. In Pakistan, inflows in March 2024 were about US\$2.95 billion, up more than 31% from the previous month, which Business Recorder (2024) attributed to Ramadan, zakat and Eid spending. In Bangladesh, the record monthly inflow of March 2025 came in the month of Eid al-Fitr (The Business Standard, 2025).

Festival peaks are also known in other remittance corridors; Philippine remittances, for example, peak in December. The difference is that Christmas falls on a fixed date, so ordinary monthly seasonal terms absorb it. The Eids move about 11 days earlier each Gregorian year, so the surge falls in a different month over time, and fixed monthly seasonality cannot capture it. This is the motivation for modelling Eid explicitly.

## 2.4 Related Empirical Studies: Islamic-Calendar Effects in Economic Time Series

Studies across Muslim-majority economies find that Islamic holidays leave a clear mark on monthly economic series, and that ignoring them distorts seasonal adjustment and forecasts. The closest work comes from the State Bank of Pakistan. Riazuddin and Khan (2005) extend ARIMA models with fractional Islamic-calendar indicators and find strong effects in Pakistan's currency in circulation; they argue that conventional seasonal adjustment gives distorted results in Islamic countries. Bukhari et al. (2011) find that Ramadan and Zilhaj raise currency holdings, lower deposits and coincide with higher CPI, and that ignoring these effects biases monthly models and forecasts. Riazuddin (2012) builds Hijri-month series for Pakistan's CPI.

The only study found that applies holiday terms to remittances is Bokhari and Ansari (2009). They seasonally adjusted five Pakistani financial series, including workers' remittances, with X-12-ARIMA and included Ramadan and Dul-Haj regressors. Their aim was seasonal adjustment, not forecasting: they did not test whether the holiday terms improve out-of-sample forecasts, did not model Eid al-Fitr separately, and did not cover Bangladesh. Similar effects are documented outside South Asia (Table 2.1).

Table: Table 2.1: Studies of lunar and Islamic holiday effects outside South Asia

| Study | Country | Series | Holiday treatment |
|:---|:---|:---|:---|
| Grun Rehomme and Ben Rejeb (2008) | Tunisia | Imports, employment, energy, money supply | Before, during and after windows for Ramadan, Eid al-Fitr and Eid al-Adha; lengths chosen by AICc and forecast error |
| Aruoba and Alper (2004) | Turkey | Macroeconomic series | Conventionally adjusted series still contain Hijri-holiday seasonality |
| Australian Bureau of Statistics (2005) | Australia | Visitor arrivals from Indonesia | RegARIMA with 6 days before and 6 after Ramadan/Eid |
| Badan Pusat Statistik (2019) | Indonesia | Quarterly GDP by expenditure | Ramadan-effect adjustment |
| Lin and Liu (2002) | Taiwan | Unemployment, production | Before, around and after windows for Chinese New Year |

The common finding is that lunar holidays shift economic activity between calendar months, and that this shift has to be modelled directly. Most of this work concerns money, prices, trade and output. Remittances, which are transfers made specifically to fund holiday spending, have received little attention.

## 2.5 Statistical Methods Applied in Similar Contexts

### 2.5.1 Moving-holiday regressors

The standard way to model a holiday that changes date is a regression on the share of a pre-holiday window that falls in each month, with ARIMA errors. Bell and Hillmer (1983) assume that activity shifts by a constant amount on each of the w days before a holiday, so the monthly regressor is the proportion of that window falling in the month. The US Census Bureau's X-12-ARIMA, now X-13ARIMA-SEATS, uses this construction for Easter within the RegARIMA model (Findley et al., 1998).

Three points from this literature bear on the present study. First, Lin and Liu (2002) extend the Bell–Hillmer regressor to Chinese New Year in Taiwan and show that seasonal factors cannot be estimated consistently without controlling for the holiday; Grun Rehomme and Ben Rejeb (2008) apply the same approach to Islamic feasts in Tunisia. Second, X-12-ARIMA chooses the Easter window by comparing models with w = 1, 8 and 15 days, and with no Easter term, by AICc (Findley et al., 2005). Lin and Liu and Grun Rehomme and Ben Rejeb also choose window lengths by AICc together with out-of-sample forecast errors. The chosen lengths vary widely by series; in Tunisia, Eid al-Fitr windows range from 7 to 41 days. Findley et al. (2005) warn that AICc-based choice can be sensitive to outliers and sample length. Third, most applications to lunar holidays add during- or after-holiday terms to the pre-holiday window (Australian Bureau of Statistics, 2005; Grun Rehomme & Ben Rejeb, 2008).

### 2.5.2 Interventions and order selection

One-off events are handled with intervention variables. Box and Tiao (1975) introduced intervention analysis for known events in time series. Chen and Liu (1993) set out the standard outlier types, namely an additive outlier affecting one month, a level shift, and a temporary change that decays, together with a procedure for detecting them; this procedure is implemented in the R package tsoutliers. ARIMA orders are commonly selected automatically with the Hyndman and Khandakar (2008) algorithm in the R package forecast.

### 2.5.3 Remittance forecasting studies

Forecasting studies of remittances to Bangladesh rely mainly on ARIMA-type models with either annual data or Gregorian seasonality, and none of those found models Eid (Table 2.2).

Table: Table 2.2: Remittance forecasting studies reviewed

| Study | Country | Data | Models | Holiday terms |
|:---|:---|:---|:---|:---|
| Saha and Khanam (2022) | Bangladesh | Annual, 1999–2020 | VECM, ARIMA | None |
| Nyoni (2019) | Bangladesh | Annual, 1976–2017 | ARIMA(2,2,0) | None |
| Islam et al. (2018) | Bangladesh | Bangladesh Bank, 1998–2003 | SARIMA, GARCH | Not reported |
| de Padua et al. (2024) | Pakistan | Monthly bilateral, 2003–2021 | Bayesian VAR (drivers, not forecast evaluation) | None |
| Khan and Gunwant (2024) | Yemen | Annual, 2000–2019 | ARIMA | None |

Three limitations recur. First, annual data cannot show festival effects at all. Second, monthly studies treat seasonality as fixed by Gregorian month, which cannot follow a holiday that moves about 11 days a year. Third, models are compared on in-sample fit or simple error measures such as RMSE and MAPE, without formal tests of whether one model's forecasts are significantly better than another's. Work on Pakistan has focused on the macroeconomic drivers of remittances: de Padua et al. (2024) find that activity, inflation, equity markets and interest rates in Pakistan and host countries affect remittances, with effects that change over time.

### 2.5.4 Forecast evaluation

The forecasting literature recommends judging a model by its out-of-sample forecasts, simulated with a rolling origin, and testing differences in accuracy formally. Tashman (2000) recommends rolling-origin designs, in which the model is re-estimated at each forecast origin using only data available at that point; this yields many forecasts per horizon instead of a single hold-out test. Hyndman and Koehler (2006) review accuracy measures such as RMSE, MAPE and the mean absolute scaled error.

Diebold and Mariano (1995) test whether two forecasts have equal expected loss, and Harvey et al. (1997) correct the test for small samples and multi-step horizons. Diebold (2015) cautions that the test was designed to compare forecasts, not models, and that it is not suited to nested models. When one model nests the other, as the baseline does within the same model plus Eid regressors, the Diebold–Mariano test is undersized: estimating the extra parameters adds noise that favours the smaller model even when the larger one is correct. Clark and West (2007) adjust the loss difference for this noise; in their simulations the adjusted test has close to correct size. When several horizons or countries are tested, Holm's (1979) step-down procedure controls the chance of at least one false rejection and is less conservative than the Bonferroni correction.

## 2.6 Identified Research Gaps

The Eid surge in Bangladesh's remittances is widely reported but has not been modelled, and no study tests whether Eid regressors improve remittance forecasts. The literature establishes that remittances to Bangladesh and Pakistan are large and shift with policy (Section 2.2); that migrants have reason to remit more before festivals (Section 2.3); that Islamic holidays distort monthly economic series and can be modelled with Bell–Hillmer regressors in RegARIMA models (Sections 2.4 and 2.5); and that formal tests exist for comparing forecasts from nested models (Section 2.5.4).

The gap lies where these meet. Bangladesh remittance forecasting studies use annual data or Gregorian seasonality and do not model Eid. The only study found that applies Islamic-holiday terms to remittances, Bokhari and Ansari (2009) for Pakistan, aimed at seasonal adjustment and did not evaluate forecasts. To our knowledge, no study:

- estimates separate Eid al-Fitr and Eid al-Adha effects on Bangladesh's monthly remittances;

- tests formally whether Eid regressors improve out-of-sample remittance forecasts; or

- compares Eid effects between Bangladesh and Pakistan, two large remittance recipients with similar festival calendars.

This study addresses all three, with Bangladesh as the main case and Pakistan as the comparison. Chapter 3 describes the data and methods used to do so.

# Chapter 3`<w:r><w:br/></w:r>`{=openxml}Methods and Materials

## 3.1 Data Source and Description

This chapter describes the data and methods used to answer RQ1 and RQ2. Both countries are analysed with identical code and evaluated on the same target months. The data are summarised in Table 3.1.

Table: Table 3.1: Data sources

| | Bangladesh | Pakistan |
|:---|:---|:---|
| Source | Bangladesh Bank, *Monthly Economic Trends*, Table XVIII (Table XXI in earlier issues); each month taken from the latest issue that prints it | State Bank of Pakistan, workers' remittances; SBP release file to December 2024, SBP bulletins and press figures from January 2025 |
| Series | US\$ million, not seasonally adjusted | US\$ million, original (not seasonally adjusted) series |
| Span | July 2009 – June 2026 (204 months) | July 2005 – June 2026 (252 months) |
| Transformation | Natural log | Natural log |

Each country's full span is used, and levels are never compared across countries. For Bangladesh, each month's value is taken from the most recent issue of *Monthly Economic Trends* that prints it, so revised figures replace first releases. The August 2024 value equals Bangladesh Bank's first-released figure (US\$2.22 billion), and the FY2023-24 and FY2024-25 totals match the published figures. For Pakistan, values from January 2025 onward come from SBP bulletins and press releases citing SBP, because the consolidated release file ended in December 2024.

**Eid dates.** Each country's national Eid dates were taken from news reports of the national moon-sighting announcements, with a source recorded for each event. Where no date could be sourced, the Umm al-Qura calendar date was used and flagged; this applied to 2 of 36 in-sample events for Bangladesh and 10 of 44 for Pakistan. National dates matter because Bangladesh and Pakistan often celebrate Eid one day after Saudi Arabia, and a one-day shift moves part of the window between months.

## 3.2 Study Variables

The dependent variable is the natural log of monthly workers' remittances in US\$ million. The independent variables are the two Eid regressors and the intervention regressors (Table 3.2).

Table: Table 3.2: Study variables

| Variable | Type | Definition |
|:---|:---|:---|
| log Y~t~ | Dependent | Natural log of monthly workers' remittances, US\$ million |
| Fitr~t~ | Independent | Share of the 30-day window ending on Eid al-Fitr day that falls in month t (0 to 1) |
| Adha~t~ | Independent | Share of the 30-day window ending on Eid al-Adha day that falls in month t (0 to 1) |
| Z~t~ | Control | Intervention regressors (additive outlier, level shift or temporary change) selected by the rule in Section 3.4.3 |
| ε~t~ | Error | SARIMA process capturing trend, Gregorian seasonality and short-run dependence |

**Eid regressors.** For month t and an Eid on day D, the regressor equals the share of the w-day window ending on Eid day (inclusive) that falls in month t:

$$E^{(w)}_t = \frac{n_t}{w}$$

where n~t~ is the number of the w days from D − w + 1 to D (inclusive) that fall in month t.

A window entirely inside one month gives 1 in that month; a window split across two months is divided between them. For example, if Eid falls on 10 April, the 30-day window runs from 12 March to 10 April. March contains 20 of the 30 days, so March = 20/30 = 0.67; April contains 10 days, so April = 0.33; every other month is 0. The window length w is chosen by model fit (Section 3.4.4); the chosen length, 30 days, is roughly the length of Ramadan. The regressors are the raw window shares, not centred on their long-run monthly means as in X-13ARIMA-SEATS, because the aim here is forecasting and effect estimation rather than seasonal adjustment. Figure 3.1 shows how the Eid dates move through the calendar over the sample.

![Figure 3.1: National Eid dates in Bangladesh, 2005–2026, by calendar month](fig/fig_eid_dates.png){width=6in}

## 3.3 Conceptual Framework

Figure 3.2 summarises the framework. Log remittances are explained by three components: the Eid regressors, built from national Eid dates; the trend and Gregorian seasonality, captured by the SARIMA errors; and documented one-off shocks, entered as intervention regressors only when they pass the intervention rule. The fitted model answers RQ1 through the Eid coefficients, and RQ2 through a comparison of forecasts from the model with and without the Eid regressors.

![Figure 3.2: Conceptual framework of the study](fig/fig_framework.png){width=6in}

## 3.4 Statistical and Computational Methods

### 3.4.1 The RegARIMA model

The model for each country is a regression with seasonal ARIMA errors:

$$\log Y_t = \beta_0 + \beta_F\, \mathrm{Fitr}_t + \beta_A\, \mathrm{Adha}_t + \gamma' Z_t + \varepsilon_t, \qquad \varepsilon_t \sim \mathrm{SARIMA}(p,d,q)(P,D,Q)_{12}$$

With differenced errors, a drift term replaces the intercept and linear trend; it is considered when d + D = 1 and kept only if it lowers AICc. Two models are compared throughout:

- **Baseline:** Z only, with no Eid regressors.

- **Model with Eid regressors:** Z plus Fitr and Adha, with identical orders, training data and interventions.

**Order selection.** Orders are chosen by auto.arima (Hyndman & Khandakar, 2008) on the baseline, given Z: exhaustive search over p, q ≤ 3 and P, Q ≤ 1, d chosen by the KPSS test, D by the default seasonal-strength test, and AICc as the criterion. The choice of D is checked with the OCSB and Canova–Hansen seasonal unit-root tests. The same orders are used for the model with Eid regressors, so the two models differ only in the Eid regressors.

**Effects** are reported as percentage changes for a month that contains the full 30-day window, relative to a month containing none of it:

$$\%\Delta = 100\,\big(e^{\beta}-1\big)$$

with 95% confidence intervals from the Hessian-based standard errors.

### 3.4.2 Intervention variables

Three standard intervention types are used (Chen & Liu, 1993). For an event in month τ:

- an **additive outlier (AO)** affects month τ only: AO~t~ = 1 if t = τ, 0 otherwise;

- a **level shift (LS)** is a permanent step: LS~t~ = 1 if t ≥ τ, 0 otherwise;

- a **temporary change (TC)** decays geometrically: TC~t~ = δ^t−τ^ for t ≥ τ, 0 otherwise, with δ = 0.7, so the effect falls by 30% each month.

### 3.4.3 Intervention rule

An intervention enters the model only if (1) it is on a candidate list of events with a dated external reason (Table 3.3), (2) it is detected statistically on the model with Eid regressors, and (3) at least 3 observations after its date lie in the training window. The selected set is used in both models of the pair. The two conditions together prevent dummies being added for every awkward month, while still allowing documented shocks to be modelled.

Table: Table 3.3: Candidate interventions

| ID | Country | Window | External reason |
|:---|:---|:---|:---|
| B1 | Bangladesh | Jul 2019 | 2% cash incentive on formal-channel remittances |
| B2 | Bangladesh | Mar – Jul 2020 | COVID-19: lockdowns, job losses, disruption of informal (hundi) channels |
| B3 | Bangladesh | Jan 2022 | Incentive raised from 2% to 2.5% |
| B4 | Bangladesh | Sep 2022 | Cap on the remittance exchange rate |
| B5 | Bangladesh | Aug – Oct 2024 | Change of government; rise in formal-channel remittances |
| P1 | Pakistan | Oct 2008 – Jan 2009 | Global financial crisis shock to Gulf labour markets |
| P2 | Pakistan | Apr – Jun 2009 | Pakistan Remittance Initiative launched |
| P3 | Pakistan | Jul 2016 | Contraction of the Gulf labour market |
| P4 | Pakistan | Mar – Jul 2020 | COVID-19 |
| P5 | Pakistan | Sep 2022 | Widening interbank–open-market exchange-rate gap |
| P6 | Pakistan | Sep 2023 | Crackdown on currency smuggling and the kerb market |

**Detection.** The model with Eid regressors is fitted with airline errors, SARIMA(0,1,1)(0,1,1)~12~. For each month in an eligible candidate window, an AO, a TC and an LS are tested in turn. The critical value is the tsoutliers default: 3 for n ≤ 50, 4 for n ≥ 450, and 3 + 0.0025(n − 50) in between, which gives about 3.38 for Bangladesh and 3.50 for Pakistan on the full samples. This is stricter than the usual 1.96 because many dates are tested. Forward selection adds the term with the largest |t| above the critical value until none passes, with at most 2 interventions per candidate window.

### 3.4.4 RQ1: estimation and tests

**Descriptive check.** Before any model is fitted, each month's value is compared with a centred 12-month (2 × 12) moving average, and the mean percentage deviation is reported for months containing at least half, less than half and none of a 30-day pre-Eid window.

Each country's model is fitted on its full span. The cross-country test compares the coefficients for each Eid, H₀: β~BD~ = β~PK~, with the z-statistic for coefficients from independent samples (Paternoster et al., 1998):

$$z = \frac{\hat\beta_{BD} - \hat\beta_{PK}}{\sqrt{\mathrm{se}_{BD}^2 + \mathrm{se}_{PK}^2}}$$

**Diagnostics.** The Ljung–Box test at lag 24, the residual ACF and the Jarque–Bera test are reported. Heteroskedasticity- and autocorrelation-consistent (HAC) standard errors are computed on the GLS-transformed regression with two kernels, Newey–West and the Andrews quadratic spectral kernel, both with prewhitening. A moving-block bootstrap (block length 24, 999 replications) is also used. All are reported alongside the model-based standard errors. If a residual test fails, alternative error specifications are fitted and compared by AICc, the Ljung–Box test and the stability of the Eid coefficients.

**Window length.** The window length is chosen by AICc among 21, 30, 45 and 60 days, using only data up to June 2017, before the forecast evaluation period, so the evaluation months play no part in the choice. Orders and interventions are selected on the same data and held fixed across windows. The window with the lowest AICc in both countries is used; windows of 21 and 45 days are reported as sensitivity checks.

### 3.4.5 RQ2: forecast evaluation

**Design.** Forecasts are evaluated with a rolling origin and an expanding training window (Tashman, 2000). The first origin is June 2017 for both countries, so both are evaluated on the same target months, July 2017 – June 2026. At each origin, interventions and orders are re-selected using only data available at that origin, both models are fitted, and forecasts are made for h = 1, …, 12 months ahead. The primary horizons are h = 1 and h = 3, which give 108 one-month-ahead and 106 three-month-ahead forecasts per country. Results at other horizons are reported without correction for multiple testing.

**Accuracy measures.** RMSE and mean error (bias) of the log forecasts, RMSE in US\$ million, and MAPE. The improvement from the Eid regressors is

$$\text{Improvement (\%)} = 100 \times \frac{\mathrm{RMSE}_{\text{baseline}} - \mathrm{RMSE}_{\text{Eid}}}{\mathrm{RMSE}_{\text{baseline}}}$$

Accuracy is also reported separately for target months with a non-zero Eid regressor value (Eid months) and for the other months.

**Tests.** The tests are summarised in Table 3.4. Because the baseline is nested in the model with Eid regressors, the Clark–West test is primary. For forecast errors e~1,t~ (baseline) and e~2,t~ (model with Eid regressors) and forecasts ŷ~1,t~ and ŷ~2,t~, the Clark–West test regresses the adjusted loss difference

$$f_t = e_{1,t}^2 - \left[\, e_{2,t}^2 - (\hat y_{1,t} - \hat y_{2,t})^2 \,\right]$$

on a constant and uses a one-sided t-test with a Newey–West variance with h − 1 lags.

Table: Table 3.4: Forecast comparison tests

| Test | Role | Details |
|:---|:---|:---|
| Clark–West | Primary (the models are nested) | Squared log error; one-sided; Newey–West variance with h − 1 lags; Holm correction over 4 tests (2 countries × h = 1, 3) at α = 0.05 |
| Diebold–Mariano | Secondary | Absolute-error loss; Harvey–Leybourne–Newbold correction; two-sided |

**Benchmarks.** A seasonal naive forecast, and a Box–Jenkins SARIMA(0,1,1)(1,1,1)~12~ model identified once from ACF and PACF plots on data to June 2017, with coefficients re-estimated at every origin.

### 3.4.6 Sensitivity analyses

Table: Table 3.5: Sensitivity analyses

| ID | Change from the main specification |
|:---|:---|
| S1 | Eid windows of 21 and 45 days |
| S2 | Fixed airline orders, SARIMA(0,1,1)(0,1,1)~12~, at every origin |
| S3 | No interventions |

### 3.4.7 Prior exploratory analyses

An earlier exploratory analysis of the Bangladesh series by the author found forecast improvements at short horizons, which informed the choice of primary horizons. Exploratory Pakistan analyses, including an outlier search, were run before the candidate intervention list was finalised.

## 3.5 Software and Packages Used

All analysis was done in R 4.3.3 (R Core Team). Models were fitted with the forecast package (Hyndman & Khandakar, 2008), HAC standard errors computed with sandwich and lmtest, and figures drawn in base R. Outlier detection follows the Chen–Liu procedure with the defaults of tsoutliers::tso (checked against tso on the full samples). Eid dates were compiled and converted with Python (hijri-converter). The code and data are kept in the repository github.com/sharofsh/bd-pk-eid-remittances (Appendix E). Chapter 4 presents the results of applying these methods.

# Chapter 4`<w:r><w:br/></w:r>`{=openxml}Results and Discussion

Both Eids are associated with higher remittances in both countries, with no evidence of a difference between the two countries. Including Eid regressors improves 1- and 3-month-ahead forecasts in both countries; at longer horizons the evidence is weaker.

## 4.1 Descriptive Statistics

Table 4.1 summarises the two series. Average monthly remittances are similar in the two countries, about US\$1.5–1.6 billion, but Pakistan's series starts four years earlier from a much lower level. Over their spans, annual totals rose about threefold in Bangladesh and ninefold in Pakistan (Appendix Table A.2). Month-on-month changes are volatile: the standard deviation of the monthly log change is about 13–14 percentage points.

Table: Table 4.1: Descriptive statistics of monthly workers' remittances (US\$ million)

| Statistic | Bangladesh | Pakistan |
|:---|---:|---:|
| Span | Jul 2009 – Jun 2026 | Jul 2005 – Jun 2026 |
| Months (n) | 204 | 252 |
| Mean | 1,539 | 1,621 |
| Standard deviation | 592 | 889 |
| Minimum (month) | 828 (Feb 2010) | 309 (Nov 2005) |
| Maximum (month) | 3,752 (Mar 2026) | 4,251 (May 2026) |
| Mean monthly log change (%) | 0.57 | 0.96 |
| SD of monthly log change (%) | 13.9 | 13.1 |
| FY2025-26 total | 35,594 | 41,582 |

Figure 4.1 plots both series and marks the months that contain at least half of a 30-day pre-Eid window. In most years these months are local peaks, and the peaks move earlier through the calendar as the Eids do. Both series also show a fall in early 2020 followed by a sharp rise from June 2020, and Bangladesh shows a further rise after August 2024.

![Figure 4.1: Monthly workers' remittances with Eid months marked](fig/fig_series.png){width=6.2in}

Table 4.2 and Figure 4.2 compare each month with a centred 12-month moving average. Months containing at least half of a pre-Eid window lie about 9–10% above trend in both countries, and months containing none of it about 2% below. Months containing less than half of a window are close to trend (−1.9% and −0.5%), not above it as the window-share regressor implies. Such months usually contain Eid day and the days after it, so a fall in remittances after Eid may offset the pre-Eid rise; the model does not include a post-Eid term (Section 5.3).

Table: Table 4.2: Mean percentage deviation from a centred 12-month moving average, by share of the pre-Eid window in the month

| Share of a 30-day pre-Eid window in the month | Bangladesh: months | Bangladesh: deviation (%) | Pakistan: months | Pakistan: deviation (%) |
|:---|---:|---:|---:|---:|
| Half or more | 32 | +9.8 | 40 | +9.2 |
| Under half | 30 | −1.9 | 38 | −0.5 |
| None | 130 | −2.3 | 162 | −2.2 |

![Figure 4.2: Deviation from trend by share of the pre-Eid window in the month](fig/fig_ratio.png){width=6.2in}

## 4.2 Model Estimation Results and Interpretations

Sections 4.2.1–4.2.5 address RQ1 and Sections 4.2.6–4.2.7 address RQ2.

### 4.2.1 Window length and selected specifications

Table 4.3 compares model fit across window lengths on data up to June 2017, before the forecast evaluation period. Adding Eid regressors of any length improves AICc. The 30-day window fits best in both countries: by 6.6 AICc points over the 21-day window for Bangladesh and by 5.8 for Pakistan. The 45-day window is close in Bangladesh (0.7 points) and further behind in Pakistan (2.5 points). Under the rule in Section 3.4.4, 30 days is used as the main window. On the full sample the ranking is the same, with 30 days ahead of 21 days by 12.0 points (Bangladesh) and 20.1 points (Pakistan).

Table: Table 4.3: Model fit (AICc) by Eid window length, data up to June 2017 (lower is better)

| Window | Bangladesh (n = 96) | Pakistan (n = 144) |
|:---|---:|---:|
| No Eid regressors | −189.1 | −285.7 |
| 21 days | −197.0 | −300.1 |
| **30 days** | **−203.6** | **−306.0** |
| 45 days | −203.0 | −303.5 |
| 60 days | −195.1 | −294.4 |

Note: Orders and interventions are selected on the same data and held fixed across windows: Bangladesh SARIMA(2,1,0)(0,0,1)~12~ with no interventions; Pakistan SARIMA(0,1,1)(1,0,0)~12~ with drift and additive outliers in October 2008 and July 2016.

The selected full-sample specifications are shown in Table 4.4. Bangladesh's model is SARIMA(0,1,1)(0,0,1)~12~ without drift, with two level shifts for COVID-19: a fall in March 2020 and a rise in June 2020. Pakistan's model is SARIMA(3,1,1)(1,0,0)~12~ with drift, two additive outliers (October 2008 and July 2016) and a level shift in June 2020. In both countries the seasonal-strength, OCSB and Canova–Hansen tests indicated no seasonal differencing (D = 0).

Table: Table 4.4: Selected specifications (full sample, 30-day window)

| Country | Orders | Interventions selected |
|:---|:---|:---|
| Bangladesh | SARIMA(0,1,1)(0,0,1)~12~ | LS Mar 2020, LS Jun 2020 (B2) |
| Pakistan | SARIMA(3,1,1)(1,0,0)~12~ + drift | AO Oct 2008 (P1), AO Jul 2016 (P3), LS Jun 2020 (P4) |

Both Pakistan additive outliers fall in months that begin with Eid al-Fitr (1 October 2008 and 6 July 2016). They may therefore partly capture a post-Eid fall rather than the listed external events. Candidate B5 (Bangladesh, August – October 2024) was not selected on the full sample or at any forecast origin; in the 21-day analysis its level-shift t-statistic was 2.72, below the critical value of 3.38. The rise after August 2024 was gradual rather than a single step.

### 4.2.2 Eid effects (RQ1)

Table 4.5 gives the estimated Eid effects. With the 30-day window, a month containing the full window before Eid al-Fitr has about 19.6% higher remittances than a month containing none of it, in both countries. The Eid al-Adha association is 20.5% in Bangladesh and 14.9% in Pakistan. All four coefficients are significant at p < 0.001, so H1 is rejected for every country and Eid. With a 21-day window the effects are smaller, 11–17% (Table 4.7).

Table: Table 4.5: Estimated Eid effects (% change for a month containing the full 30-day window; 95% confidence interval)

| Country | Eid al-Fitr | Eid al-Adha |
|:---|:---|:---|
| Bangladesh (n = 204) | 19.6 [12.4, 27.2] | 20.5 [13.3, 28.1] |
| Pakistan (n = 252) | 19.6 [14.3, 25.2] | 14.9 [9.8, 20.3] |

For a typical Bangladesh month of US\$2.5 billion, a 19.6% difference is roughly US\$490 million. When the window is split, the effect is divided in proportion. For an Eid al-Fitr on 10 April, March holds 0.67 of the window and is predicted about 0.67 × 0.179 = 0.12 log points higher (about +12.7%), and April, holding 0.33, about +6.2%.

### 4.2.3 Cross-country comparison

The data give no evidence that the Eid effects differ between the two countries (Table 4.6), so H2 is not rejected. The Eid al-Fitr coefficients are almost identical; the Eid al-Adha coefficient is 0.047 log points larger in Bangladesh, within sampling error. With standard errors of about 0.039, however, the test could not detect differences smaller than roughly 0.08 log points (about 8 percentage points), so the result does not show that the effects are equal.

Table: Table 4.6: Cross-country difference in Eid effects (Bangladesh − Pakistan, log points)

| Eid | Difference | SE | p-value |
|:---|---:|---:|---:|
| Eid al-Fitr | −0.001 | 0.039 | 0.99 |
| Eid al-Adha | +0.047 | 0.039 | 0.23 |

### 4.2.4 Diagnostics and robustness of inference

Bangladesh's residuals pass both diagnostic tests: Ljung–Box(24) p = 0.17 and Jarque–Bera p = 0.80. Pakistan's residuals are consistent with normality (Jarque–Bera p = 0.43) but fail the Ljung–Box test at lag 24 (p = 0.014); the test passes at lag 12 (p = 0.22), and the remaining autocorrelation is at lags 13, 14 and 35 (Appendix D). With HAC standard errors (Andrews quadratic spectral kernel), the Pakistan standard errors rise from 0.023 to 0.027 (Eid al-Fitr) and 0.025 (Eid al-Adha), and all four Eid effects remain significant at p < 0.001. Other robust methods give similar results (Appendix Table D.1). Five alternative error specifications for Pakistan also failed the Ljung–Box test and had higher AICc, with Eid coefficients of 0.15–0.18 (Eid al-Fitr) and 0.13–0.15 (Eid al-Adha) (Appendix Table D.2).

### 4.2.5 Sensitivity of the Eid effects

The Eid effects are positive and significant under every sensitivity specification (Table 4.7). Their size depends on the window length: a longer window spreads the extra transfers over more days, so the coefficient for a full window is larger. The relative size of the two Eids is not stable: in Bangladesh the Eid al-Adha effect is larger at 21 and 30 days but smaller at 45 days. The cross-country test was run for the main specification only.

Table: Table 4.7: Sensitivity of the Eid effects (Eid al-Fitr % / Eid al-Adha %)

| Specification | Bangladesh | Pakistan |
|:---|:---|:---|
| Main (30 days) | 19.6 / 20.5 | 19.6 / 14.9 |
| S1, 21 days | 13.8 / 16.6 | 14.5 / 11.3 |
| S1, 45 days | 24.3 / 20.5 | 26.4 / 20.9 |
| S2, airline orders | 18.7 / 22.5 | 15.9 / 15.1 |
| S3, no interventions | 17.1 / 23.7 | 18.3 / 16.9 |

Note: All 95% confidence intervals in this table exclude zero.

### 4.2.6 Forecast accuracy (RQ2)

Table 4.8 reports the primary tests. All four Clark–West tests reject at 5% after the Holm correction, so H3 is rejected at the primary horizons: the Eid regressors have predictive content in both countries. The Diebold–Mariano tests, which compare realised accuracy, are also significant at 5%. One month ahead, RMSE is 9.8% lower in Bangladesh and 11.6% lower in Pakistan. Three months ahead the reduction is 2.1% in Bangladesh and 9.2% in Pakistan.

Table: Table 4.8: Primary forecast comparison (target months Jul 2017 – Jun 2026)

| Country, horizon | n | Clark–West t | Holm-adjusted p | Diebold–Mariano p | RMSE improvement (%) |
|:---|---:|---:|---:|---:|---:|
| Bangladesh, h = 1 | 108 | 3.30 | 0.0010 | 0.014 | 9.8 |
| Bangladesh, h = 3 | 106 | 2.09 | 0.018 | 0.035 | 2.1 |
| Pakistan, h = 1 | 108 | 3.66 | 0.0005 | 0.007 | 11.6 |
| Pakistan, h = 3 | 106 | 3.66 | 0.0005 | 0.040 | 9.2 |

Figure 4.3 shows the RMSE change at every horizon. For Pakistan, RMSE is lower at every horizon and the unadjusted Clark–West p-value is below 0.05 at each. For Bangladesh, the improvement shrinks to about zero by h = 6 and is slightly negative at long horizons (−1.4% at h = 12), although the Clark–West statistic stays positive; this is possible because the test concerns predictive content in population rather than realised accuracy. These longer-horizon results are not corrected for multiple testing (Appendix C).

Bangladesh forecasts under-predict increasingly with horizon: the mean log error of the model with Eid regressors is +0.014 at h = 1, +0.049 at h = 6 and +0.086 at h = 12. The Bangladesh model has no drift term, while remittances grew steadily over the evaluation period, especially after August 2024. The growing bias is therefore likely to reflect trend growth that the model does not capture, rather than the Eid regressors. In Pakistan, whose model includes drift, the mean error stays close to zero.

![Figure 4.3: RMSE improvement from the Eid regressors by forecast horizon](fig/fig_rmse_h.png){width=6.2in}

**Benchmarks.** At h = 1 and 3, the model with Eid regressors has the lowest RMSE of the four models in both countries, and the lowest MAPE at h = 1 (Table 4.9). In Pakistan the Box–Jenkins model is slightly more accurate than the baseline at h = 1 (RMSE 0.101 against 0.106), so the gain over the best model without Eid regressors is smaller, about 8%; this difference was not tested formally. At h = 12 the Box–Jenkins model is more accurate than the model with Eid regressors for Bangladesh (Appendix C).

Table: Table 4.9: Forecast accuracy against benchmarks (RMSE of log forecasts; MAPE and RMSE in US\$ million on levels)

| Model | BD h=1 RMSE | BD h=1 MAPE % | BD h=1 RMSE US\$m | BD h=3 RMSE | PK h=1 RMSE | PK h=1 MAPE % | PK h=1 RMSE US\$m | PK h=3 RMSE |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|
| Baseline | 0.139 | 10.6 | 263 | 0.164 | 0.106 | 8.3 | 251 | 0.119 |
| **Model with Eid regressors** | **0.125** | **9.6** | **230** | **0.160** | **0.093** | **7.4** | **214** | **0.108** |
| Box–Jenkins SARIMA | 0.137 | 10.5 | 264 | 0.166 | 0.101 | 8.1 | 240 | 0.116 |
| Seasonal naive | 0.219 | 16.8 | 413 | 0.221 | 0.182 | 13.9 | 439 | 0.183 |

**Eid months and other months.** Most of the improvement comes in Eid months (Table 4.10). One month ahead, RMSE falls by about 20% in target months with a non-zero Eid regressor and by 2–4% in other months. This descriptive comparison indicates that the gain is linked to the Eid regressors rather than to a general improvement in fit.

Table: Table 4.10: RMSE improvement at h = 1 by type of target month

| Target months | Bangladesh (%) | Pakistan (%) |
|:---|---:|---:|
| With a non-zero Eid regressor | 20.7 | 19.5 |
| Without | 1.9 | 3.5 |

Note: For Bangladesh, 37 of the 108 target months have a non-zero Eid regressor.

**Examples.** Table 4.11 shows three one-month-ahead forecasts. In March 2025, when the whole Eid al-Fitr window fell in March, the Eid regressors reduced Bangladesh's forecast error by about US\$340 million, although both models under-predicted a record month. In June 2024, with 57% of the Eid al-Adha window in June, the model with Eid regressors was US\$66 million closer for Pakistan. It does not improve every Eid month: for Bangladesh in June 2024 the two forecasts were practically the same.

Table: Table 4.11: Examples of one-month-ahead forecasts (US\$ million)

| Target month | Eid | Actual | Baseline forecast | Forecast with Eid regressors | Error reduction |
|:---|:---|---:|---:|---:|---:|
| Bangladesh, Mar 2025 | Eid al-Fitr, 31 Mar (100% in March) | 3,296 | 2,327 | 2,668 | 341 |
| Pakistan, Jun 2024 | Eid al-Adha, 17 Jun (57% in June) | 3,158 | 2,832 | 2,898 | 66 |
| Bangladesh, Jun 2024 | Eid al-Adha, 17 Jun | 2,539 | 2,322 | 2,317 | −5 |

### 4.2.7 Sensitivity of the forecast results

With the 21-day window, all four primary Clark–West tests still reject after the Holm correction (Table 4.12). The RMSE improvements are smaller than with the 30-day window except for Bangladesh at h = 3 (4.4% against 2.1%). At h = 1 the improvement holds when the orders are fixed (S2) and when interventions are dropped (S3). At h = 3, the Clark–West t falls below 1.645 only for Bangladesh without interventions, where the RMSE change is about zero.

Table: Table 4.12: Sensitivity of the forecast comparison (Clark–West t / RMSE improvement %)

| Specification | BD h = 1 | BD h = 3 | PK h = 1 | PK h = 3 |
|:---|:---|:---|:---|:---|
| Main (30 days) | 3.30 / 9.8 | 2.09 / 2.1 | 3.66 / 11.6 | 3.66 / 9.2 |
| S1, 21 days | 3.03 / 6.7 | 2.56 / 4.4 | 2.61 / 5.2 | 3.14 / 5.4 |
| S2, airline orders | 3.95 / 11.6 | 2.65 / 2.2 | 3.13 / 7.5 | 2.66 / 2.2 |
| S3, no interventions | 3.24 / 7.2 | 1.56 / −0.2 | 3.49 / 10.0 | 3.70 / 9.4 |

Note: One-sided Clark–West tests, not corrected for multiplicity except where stated; the 45-day window was not evaluated for forecasting.

## 4.3 Comparison with Previous Studies

The estimates are in line with the few earlier studies of Islamic holidays in remittances and related series. Bokhari and Ansari (2009) found a Dul-Haj effect of about +13.8% in Pakistan's remittances using X-12-ARIMA; the Pakistan Eid al-Adha effect here, +14.9% with a 30-day window, is close to it despite the different method and sample. Grun Rehomme and Ben Rejeb (2008) found pre-Eid windows of 7 to 41 days for Tunisian series, so the 30-day window chosen here lies within the range found elsewhere, and window length appears to be series-specific. The forecasting results extend the finding of State Bank of Pakistan studies that Islamic-calendar effects bias forecasts of money and prices (Riazuddin & Khan, 2005; Bukhari et al., 2011), and of Lin and Liu (2002) for Chinese New Year, to remittances, with formal out-of-sample tests. Unlike earlier Bangladesh forecasting studies, which used annual data or Gregorian seasonality (Islam et al., 2018; Nyoni, 2019; Saha & Khanam, 2022), this study shows a statistically significant forecast gain from a moving-holiday regressor. Farabi et al. (2025) estimated a 6.68% rise after the July 2019 incentive; the incentive (B1) was not selected by the intervention rule here, and the June 2020 level shift may absorb part of the move to formal channels.

The similar size of the Eid associations in the two countries is consistent with the altruistic and family-contract motives for remitting (Lucas & Stark, 1985): migrants from both countries face similar festival spending at home. The smaller Eid al-Adha estimate for Pakistan may reflect differences in how the sacrifice is financed, but the difference is not significant. The forecast gain is concentrated at short horizons for Bangladesh, where long-horizon errors are dominated by unmodelled trend growth, and is more persistent for Pakistan. More generally, a Box–Jenkins model with Gregorian seasonality performed little better than the baseline, while two calendar regressors gave the largest short-horizon gain. This supports the view in the Islamic-calendar literature that fixed monthly seasonality is not enough for series driven by lunar holidays. Chapter 5 summarises these findings and their implications.

# Chapter 5`<w:r><w:br/></w:r>`{=openxml}Summary and Conclusions

## 5.1 Summary of Findings

Returning to the research questions set out in Chapter 1, this study examined whether the two Eid festivals are associated with changes in monthly workers' remittances to Bangladesh and Pakistan, and whether accounting for them improves remittance forecasts. Eid regressors were built from each country's national Eid dates as the share of a pre-Eid window falling in each month, and included in a RegARIMA model with interventions. Forecasts with and without the Eid regressors were compared over 108 target months, July 2017 – June 2026.

- **Eid effects (RQ1).** Both Eids are associated with significantly higher remittances in both countries. A month containing the full 30-day window has 15–21% higher remittances than a month containing none of it; with a 21-day window the figure is 11–17%. The effects remain significant under all sensitivity checks and with robust standard errors.

- **Cross-country comparison (RQ1).** There is no evidence that the effects differ between the two countries (p = 0.99 for Eid al-Fitr, p = 0.23 for Eid al-Adha), although small differences could not be detected.

- **Forecasting (RQ2).** The Eid regressors have predictive content in both countries at 1 and 3 months ahead, after the Holm correction. One month ahead, RMSE falls by 9.8% in Bangladesh and 11.6% in Pakistan with the 30-day window, and by 6.7% and 5.2% with the 21-day window. At longer horizons the gain continues in Pakistan but disappears in Bangladesh.

- **Eid months.** Forecast errors fall by about 20% in Eid months and by 2–4% in other months.

- **Benchmarks.** At 1 and 3 months ahead, the model with Eid regressors has lower RMSE than a seasonal naive forecast and a Box–Jenkins SARIMA model in both countries.

## 5.2 Policy and Practical Implications

- **For forecasters at Bangladesh Bank and the State Bank of Pakistan.** Eid dates are announced in advance and can be projected years ahead, so adding two Eid regressors to an existing ARIMA model is cheap. In this study it reduced one-month-ahead errors by about 5–12% overall and by about a fifth in Eid months.

- **For interpreting monthly data.** Month-on-month and year-on-year comparisons of remittances are distorted when Eid moves between months. A rise in an Eid month, or a fall in the month after, should not be read as a change in the underlying trend. Publishing an Eid-adjusted series alongside the raw series would help.

- **For seasonal adjustment.** Seasonal adjustment of remittances in both countries should consider Islamic-calendar regressors, as State Bank of Pakistan research recommends for monetary series.

## 5.3 Limitations of the Study

- **Prior exploratory work.** Earlier exploratory work on the Bangladesh series informed the choice of horizons, and the Pakistan candidate interventions were listed after an exploratory outlier search.

- **Post-Eid effects.** The model has only a pre-Eid window. Months holding less than half of the window are close to trend, and both Pakistan additive outliers fall in post-Eid months, which suggests a post-Eid fall that the model does not capture.

- **Residual autocorrelation for Pakistan.** The Pakistan model fails the Ljung–Box test at lag 24. Robust standard errors and alternative error specifications leave the conclusions unchanged, but the model does not capture all of Pakistan's dynamics.

- **Trend in Bangladesh.** The Bangladesh model has no drift term, and its forecasts under-predict increasingly at long horizons during a period of strong growth.

- **Calendar coverage.** Over the sample, Eid al-Fitr moved through about half the calendar, from late September to late March. The data never observe Eid in every month.

- **Data.** Pakistan's figures from January 2025 come from SBP bulletins and press releases rather than the consolidated release file. Recorded remittances exclude informal transfers, and part of the measured changes after 2019 may reflect shifts between informal and formal channels.

- **Power and multiple testing.** The cross-country test cannot detect differences smaller than about 8 percentage points, and results beyond the primary horizons are not corrected for multiple testing. The theory behind the Clark–West test covers direct multi-step forecasts, whereas the ARIMA forecasts here are iterated, so multi-step p-values are approximate.

## 5.4 Future Research Directions

- Add post-Eid and Ramadan-wide regressors, and test whether they explain the under-half-window months and the remaining residual autocorrelation for Pakistan.

- Model trend growth in Bangladesh explicitly, for example with a drift term or a time-varying level, and re-evaluate long-horizon forecasts.

- Use bilateral corridor data, for example from Gulf countries, Malaysia, the United Kingdom and the United States, to test whether Eid effects differ by host country.

- Extend the comparison to other Muslim-majority remittance recipients, such as Egypt, Morocco and Indonesia.

## 5.5 Conclusion

Both Eid festivals are associated with substantially higher monthly workers' remittances to Bangladesh and Pakistan, about 11–21% in a month containing the full pre-Eid period depending on the window length, with no evidence of a difference between the two countries. Because the Eids move through the Gregorian calendar, standard seasonal models miss this pattern. Two simple calendar regressors capture much of it and give significant, formally tested improvements in short-term forecasts in both countries.
