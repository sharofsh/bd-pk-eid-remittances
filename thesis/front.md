::: {custom-style="TitlePageTitle"}
Moving Holidays and Remittance Forecasting: Comparative Evidence from Bangladesh and Pakistan
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
Acknowledgements
:::

I thank the Department of Statistics and Data Science, Jahangirnagar University, for its support throughout the Weekend M.Sc. programme. I thank Olima Mim for her careful reading of and comments on earlier drafts. I also thank Bangladesh Bank and the State Bank of Pakistan for making their remittance data publicly available. Finally, I thank my family for their patience and support.

::: {custom-style="FrontHeading"}
Abstract
:::

Workers' remittances are a major source of foreign exchange for Bangladesh and Pakistan. Migrants send more money home before each of the two Eid festivals. The Eids follow the lunar calendar and fall about 11 days earlier each year, so this increase arrives in a different month from year to year. Standard forecasting models, which assume the same seasonal pattern every year, cannot capture it. This study asks whether Eid al-Fitr and Eid al-Adha are associated with changes in monthly remittances, whether the effects differ between the two countries, and whether accounting for Eid improves forecasts.

Monthly data from Bangladesh Bank (July 2009 to June 2026) and the State Bank of Pakistan (July 2005 to June 2026) were analysed with a regression model with seasonal ARIMA errors (RegARIMA). Pakistan is included because it celebrates the same Eids and is the only country with an earlier estimate of holiday effects on remittances. Eid regressors measure the share of the 30 days before each Eid that falls in each month. Forecasts with and without the Eid regressors were compared for July 2017 to June 2026 using the Clark-West and Diebold-Mariano tests.

A month containing the whole 30-day pre-Eid window has about 15-21% higher remittances in both countries, and the effects do not differ significantly between them. Including Eid reduces one-month-ahead forecast errors by 9.8% in Bangladesh and 11.6% in Pakistan, and by about 20% in both countries in months that contain part of a pre-Eid window. The model with Eid regressors is also significantly more accurate than a seasonal naive forecast and has lower, though not significantly lower, errors than a Box-Jenkins SARIMA model. In simple terms, migrants from both countries send about 15 to 21% more money home before each Eid, and allowing for this makes forecasts one and three months ahead more accurate.

This is one of the first studies to measure the Eid effect on remittances to Bangladesh and Pakistan and to show that it improves remittance forecasts in both.

**Keywords:** remittances, Eid, moving holidays, RegARIMA, forecast evaluation, Clark-West test, Bangladesh, Pakistan

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
| ARDL | Autoregressive distributed lag |
| ARIMA | Autoregressive integrated moving average |
| BD | Bangladesh |
| FY | Fiscal year (July to June) |
| GARCH | Generalised autoregressive conditional heteroskedasticity |
| GDP | Gross domestic product |
| GLS | Generalised least squares |
| HAC | Heteroskedasticity- and autocorrelation-consistent |
| IMF | International Monetary Fund |
| KPSS | Kwiatkowski-Phillips-Schmidt-Shin test |
| LS | Level shift |
| LSTM | Long short-term memory (neural network) |
| MAE | Mean absolute error |
| MAPE | Mean absolute percentage error |
| OCSB | Osborn-Chui-Smith-Birchenhall test |
| PK | Pakistan |
| RegARIMA | Regression model with ARIMA errors |
| RMSE | Root mean squared error |
| SARIMA | Seasonal ARIMA |
| SBP | State Bank of Pakistan |
| SE | Standard error |
| TC | Temporary change |
| US\$ | United States dollar |
| VAR | Vector autoregression |
| VECM | Vector error correction model |

```{=openxml}
<w:p><w:pPr><w:sectPr/></w:pPr></w:p>
```
