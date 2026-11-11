::: {custom-style="TitlePageTitle"}
Eid Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan
:::

::: {custom-style="Centered"}
A Thesis Submitted to the Department of Statistics and Data Science\
in Partial Fulfillment of the Requirements for the Degree of\
Weekend Master of Science in Applied Statistics and Data Science
:::

::: {custom-style="Centered"}
![](fig/logo.png){width=1.37in}
:::

::: {custom-style="Centered"}
by\
Sharof Shahrul Hoque\
Student ID: 20251601\
WM-ASDS, 16th Batch
:::

::: {custom-style="Centered"}
3rd Semester
:::

::: {custom-style="Centered"}
Department of Statistics and Data Science\
Jahangirnagar University
:::

::: {custom-style="Centered"}
November 2026
:::

::: {custom-style="FrontHeading"}
Declaration
:::

I hereby declare that this thesis is the result of my own research work and has not been submitted for any other degree or diploma at any other university or institution.

::: {custom-style="SignBlock"}
Signature of the Student\
Name: Sharof Shahrul Hoque\
Date: ____________________
:::

::: {custom-style="FrontHeading"}
Certificate of the Supervisor
:::

This is to certify that the thesis titled 'Eid Effects and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan' submitted by Sharof Shahrul Hoque for the degree of Weekend Master of Science in Applied Statistics and Data Science is based on the results of the candidate's own research work carried out under my supervision.

::: {custom-style="SignBlock"}
Signature of Supervisor\
Name: Dr. Mohammed Nazmul Huq\
Designation: Professor, Department of Statistics and Data Science, Jahangirnagar University\
Date: ____________________
:::

::: {custom-style="FrontHeading"}
Acknowledgements
:::

I am grateful to my supervisor, Professor Dr. Mohammed Nazmul Huq, for his guidance and support throughout this research. I thank the Department of Statistics and Data Science, Jahangirnagar University, for its support throughout the Weekend M.Sc. programme. I thank Bangladesh Bank and the State Bank of Pakistan for making their remittance data publicly available. Finally, I thank my family for their patience and support.

::: {custom-style="FrontHeading"}
Abstract
:::

Workers' remittances are a major source of foreign exchange for Bangladesh and Pakistan, and short-term forecasts of them support reserve and exchange-rate management. Monthly inflows rise before the two Eid festivals, but the Eids follow the lunar Hijri calendar and move about 11 days earlier each year, so standard models with fixed monthly seasonality cannot capture them. This study asks whether Eid al-Fitr and Eid al-Adha are associated with changes in monthly remittances to the two countries, whether these effects differ between them, and whether Eid regressors improve out-of-sample forecasts.

Monthly remittance data from Bangladesh Bank (July 2009 – June 2026, 204 months) and the State Bank of Pakistan (July 2005 – June 2026, 252 months) were modelled with a regression model with seasonal ARIMA errors (RegARIMA) on log remittances. Eid regressors, built from each country's national Eid dates, measure the share of a 30-day pre-Eid window falling in each month. One-off shocks such as COVID-19 entered the model only if they had a documented external cause and passed a statistical detection test. Forecasts from a baseline model and the same model with Eid regressors were compared over July 2017 – June 2026 with a rolling origin, using the Clark–West test with a Holm correction and the Diebold–Mariano test, and against seasonal naive and Box–Jenkins SARIMA benchmarks.

Both Eids are associated with significantly higher remittances. With a 30-day pre-Eid window, chosen by model fit on data before the forecast evaluation period, a month containing the full pre-Eid window has 19.6% (Eid al-Fitr) and 20.5% (Eid al-Adha) higher remittances in Bangladesh, and 19.6% and 14.9% in Pakistan; with a 21-day window the estimates are 11–17%. There is no evidence that the effects differ between the countries (p = 0.99 and 0.23). The Eid regressors reduce one-month-ahead RMSE by 9.8% in Bangladesh and 11.6% in Pakistan (6.7% and 5.2% with the 21-day window), and the Clark–West tests at one and three months ahead are significant after the Holm correction under both windows. The gain is concentrated in Eid months, where errors fall by about 20%, and fades beyond three months for Bangladesh.

Two simple calendar regressors capture a large, predictable part of the variation in monthly remittances and are worth including in remittance forecasting and seasonal adjustment in both countries.

**Keywords:** remittances, Eid, moving holidays, RegARIMA, forecast evaluation, Clark–West test, Bangladesh, Pakistan

::: {custom-style="FrontHeading"}
Table of Contents
:::

```{=openxml}
TOCMAIN
```

::: {custom-style="FrontHeading"}
List of Tables
:::

```{=openxml}
TOCTAB
```

::: {custom-style="FrontHeading"}
List of Figures
:::

```{=openxml}
TOCFIG
```

::: {custom-style="FrontHeading"}
List of Abbreviations
:::

| Abbreviation | Full Form |
|:---|:---|
| ACF / PACF | Autocorrelation function / partial autocorrelation function |
| AICc | Akaike information criterion, corrected for small samples |
| AO | Additive outlier |
| ARIMA | Autoregressive integrated moving average |
| BB | Bangladesh Bank |
| BD | Bangladesh |
| CW | Clark–West test |
| DM | Diebold–Mariano test |
| FY | Fiscal year (July to June) |
| GLS | Generalised least squares |
| HAC | Heteroskedasticity- and autocorrelation-consistent |
| HLN | Harvey–Leybourne–Newbold correction |
| KPSS | Kwiatkowski–Phillips–Schmidt–Shin test |
| LS | Level shift |
| MAPE | Mean absolute percentage error |
| ME | Mean error |
| PK | Pakistan |
| RegARIMA | Regression model with ARIMA errors |
| RMSE | Root mean squared error |
| SARIMA | Seasonal ARIMA |
| SBP | State Bank of Pakistan |
| SE | Standard error |
| TC | Temporary change |
| US\$ | United States dollar |

```{=openxml}
<w:p><w:pPr><w:sectPr/></w:pPr></w:p>
```
