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

I am grateful to my supervisor, Professor Dr. Mohammed Nazmul Huq, for his guidance and support throughout this research. I thank the Department of Statistics and Data Science, Jahangirnagar University, for its support throughout the Weekend M.Sc. programme. I thank Olima Mim for her careful reading of and comments on earlier drafts. I also thank Bangladesh Bank and the State Bank of Pakistan for making their remittance data publicly available. Finally, I thank my family for their patience and support.

::: {custom-style="FrontHeading"}
Abstract
:::

Remittances from migrant workers are a major source of foreign exchange for Bangladesh and Pakistan. Each month, migrants send more money home in the weeks before the two Eid festivals. The Eids follow the lunar calendar and fall about 11 days earlier each year, so this increase arrives in a different month from year to year. Standard forecasting models, which assume the same seasonal pattern every year, cannot capture it. This study asks whether Eid al-Fitr and Eid al-Adha are associated with changes in monthly remittances, whether the effects differ between the two countries, and whether accounting for Eid improves forecasts.

Monthly data from Bangladesh Bank (July 2009 – June 2026) and the State Bank of Pakistan (July 2005 – June 2026) were analysed with a regression model with seasonal ARIMA errors (RegARIMA). Eid regressors measure the share of a 30-day pre-Eid period falling in each month. Forecasts with and without the Eid regressors were compared for July 2017 – June 2026 using the Clark–West and Diebold–Mariano tests.

A month containing the full pre-Eid period has about 15–21% higher remittances in both countries, and the effects do not differ significantly between them. Including Eid reduces one-month-ahead forecast errors by 9.8% in Bangladesh and 11.6% in Pakistan, and by about 20% in Eid months. In simple terms, migrants from both countries send about a fifth more money before each Eid, and forecasts that allow for this are more accurate in the months around the festivals.

This is one of the first studies to measure the Eid effect on remittances to Bangladesh and Pakistan and to show that it can be used to improve remittance forecasts in both countries.

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
