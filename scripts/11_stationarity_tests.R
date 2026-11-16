# Stationarity and differencing checks on log monthly remittances (full sample)
suppressMessages({library(forecast); library(tseries); library(urca)})
bd <- read.csv("data/bd_remittances_monthly.csv"); pk <- read.csv("data/pk_remittances_monthly.csv")
mk <- function(v, y0, m0) window(ts(log(v), start = c(y0, m0), frequency = 12), end = c(2026, 6))  # sample ends Jun 2026
S <- list(BD = mk(bd$remittances_usd_mn, 2009, 7), PK = mk(pk$remittances_usd_mn, 2005, 7))
out <- do.call(rbind, lapply(names(S), function(k) {
  y <- S[[k]]; dy <- diff(y)
  k0 <- ur.kpss(y, type = "tau", lags = "short"); k1 <- ur.kpss(dy, type = "mu", lags = "short")
  data.frame(country = k, n = length(y),
    kpss_level_trend_stat = round(k0@teststat, 3), kpss_level_crit5 = k0@cval[2],
    kpss_diff_stat = round(k1@teststat, 3), kpss_diff_crit5 = k1@cval[2],
    adf_level_p = round(suppressWarnings(adf.test(y)$p.value), 3),
    adf_diff_p = round(suppressWarnings(adf.test(dy)$p.value), 3),
    ndiffs_kpss = ndiffs(y, test = "kpss"), ndiffs_adf = ndiffs(y, test = "adf"), ndiffs_pp = ndiffs(y, test = "pp"),
    nsdiffs_seas = nsdiffs(y, test = "seas"), nsdiffs_ocsb = nsdiffs(y, test = "ocsb"), nsdiffs_ch = nsdiffs(y, test = "ch"),
    seasonal_strength = round(unname(forecast:::seas.heuristic(y)), 3))
}))
dir.create("results_w30/posthoc", showWarnings = FALSE)
write.csv(out, "results_w30/posthoc/stationarity_tests.csv", row.names = FALSE)
print(t(out))
