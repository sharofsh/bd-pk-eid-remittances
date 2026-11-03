# Box-Jenkins benchmark (DESIGN.md section 7): identification on training data available at the
# first origin (to Jun 2017) only. Writes ACF/PACF plots and a candidate table; the chosen orders
# are recorded in results/benchmark_orders.csv and then held fixed at every origin.
source("scripts/lib_model.R")
dir.create("results/benchmark_identification", recursive = TRUE, showWarnings = FALSE)
out <- NULL
for (cc in c("BD", "PK")) {
  D <- load_country(cc); keep <- D$month <= as.Date("2017-06-01")
  y <- ts(D$y[keep], start = D$start, frequency = 12)
  cat("\n=====", cc, "training n =", length(y), "=====\n")
  cat("ndiffs (KPSS):", ndiffs(y), " nsdiffs (seas):", nsdiffs(y), "\n")
  w <- diff(diff(y, 12))
  png(sprintf("results/benchmark_identification/%s_acf_pacf.png", cc), 1400, 900, res = 130)
  par(mfrow = c(2, 2))
  acf(diff(y), 36, main = paste(cc, "ACF  diff(log y)")); pacf(diff(y), 36, main = paste(cc, "PACF diff(log y)"))
  acf(w, 36, main = paste(cc, "ACF  diff12(diff(log y))")); pacf(w, 36, main = paste(cc, "PACF diff12(diff(log y))"))
  dev.off()
  a <- acf(w, 36, plot = FALSE)$acf[-1]; p <- pacf(w, 36, plot = FALSE)$acf
  b <- 1.96 / sqrt(length(w))
  cat("bound +/-", round(b, 3), "\nACF  lags 1-3,12,24:", round(a[c(1:3, 12, 24)], 3),
      "\nPACF lags 1-3,12,24:", round(p[c(1:3, 12, 24)], 3), "\n")
  cands <- list(c(0,1,1,0,1,1), c(1,1,0,0,1,1), c(1,1,1,0,1,1), c(0,1,2,0,1,1), c(2,1,0,0,1,1),
                c(0,1,1,1,1,0), c(1,1,0,1,1,0), c(0,1,1,1,1,1))
  for (o in cands) {
    f <- tryCatch(Arima(y, order = o[1:3], seasonal = o[4:6]), error = function(e) NULL)
    if (is.null(f)) next
    lb <- Box.test(residuals(f), lag = 24, type = "Ljung-Box", fitdf = sum(o[c(1, 3, 4, 6)]))
    out <- rbind(out, data.frame(country = cc, model = sprintf("(%d,%d,%d)(%d,%d,%d)", o[1],o[2],o[3],o[4],o[5],o[6]),
                                 AICc = round(f$aicc, 2), LB24_p = round(lb$p.value, 3)))
  }
}
print(out, row.names = FALSE)
write.csv(out, "results/benchmark_identification/candidates.csv", row.names = FALSE)
