# X-13ARIMA-SEATS check of the Eid effects (not part of the thesis analysis).
# Run in RStudio from the repository root. Needs: install.packages("seasonal")
# (this also installs x13binary, which supplies the X-13 program).
#
# Fits two versions per country and prints the Eid coefficients as % effects:
#   B = thesis model replicated in X-13 (same ARIMA orders, same interventions,
#       no outlier search, no trading-day terms); should match Table 4.6.
#   A = X-13 defaults: automatic ARIMA (automdl), automatic AO/LS/TC outlier
#       search, trading-day test, with the same Eid regressors.

library(seasonal)

ex <- read.csv("data/eid_exposure_monthly.csv")
spec <- list(
  BD = list(file = "data/bd_remittances_monthly.csv", start = c(2009, 7),
            orders = "(0 1 1)(0 0 1)", const = FALSE,
            iv = c("ls2020.mar", "ls2020.jun")),
  PK = list(file = "data/pk_remittances_monthly.csv", start = c(2005, 7),
            orders = "(3 1 1)(1 0 0)", const = TRUE,
            iv = c("ao2008.oct", "ao2016.jul", "ls2020.jun")))

pct <- function(b) round(100 * (exp(b) - 1), 1)

for (cc in names(spec)) {
  s <- spec[[cc]]
  d <- read.csv(s$file)
  y <- ts(d$remittances_usd_mn, start = s$start, frequency = 12)
  y <- window(y, end = c(2026, 6))

  # Eid regressors, extended 24 months past the sample for X-13's forecasts
  e <- ex[ex$country == cc, ]
  e <- e[order(e$month), ]
  first <- which(substr(e$month, 1, 7) == sprintf("%d-%02d", s$start[1], s$start[2]))
  need <- length(y) + 24
  X <- as.matrix(e[first:min(nrow(e), first + need - 1), c("fitr_w30", "adha_w30")])
  if (nrow(X) < need) X <- rbind(X, matrix(0, need - nrow(X), 2))  # future Eids beyond file: 0
  xreg <- ts(X, start = s$start, frequency = 12)
  colnames(xreg) <- c("fitr", "adha")

  # B: thesis model in X-13
  mB <- seas(y, transform.function = "log",
             regression.variables = c(if (s$const) "const", s$iv),
             xreg = xreg, regression.usertype = "holiday",
             arima.model = s$orders, regression.aictest = NULL,
             outlier = NULL, x11 = "")

  # A: X-13 defaults with the Eid regressors
  mA <- seas(y, transform.function = "log",
             xreg = xreg, regression.usertype = "holiday",
             regression.aictest = "td", outlier.types = c("ao", "ls", "tc"),
             x11 = "")

  for (nm in c("B_thesis_model", "A_x13_defaults")) {
    m <- if (nm == "B_thesis_model") mB else mA
    cf <- coef(summary(m))
    cat("\n==", cc, nm, "== ARIMA:", m$model$arima$model, "\n")
    cat("Regressors:", paste(rownames(cf), collapse = ", "), "\n")
    for (v in c("xreg1", "xreg2", "fitr", "adha")) if (v %in% rownames(cf))
      cat(sprintf("  %-5s effect %5.1f%%  (z = %.2f)\n", v, pct(cf[v, 1]), cf[v, 3]))
  }
}
