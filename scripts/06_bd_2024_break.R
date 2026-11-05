# Post hoc investigation of the Bangladesh Aug 2024 break (candidate B5). NOT part of the pre-specified plan.
# Requested by Sharof on 4 Nov 2026 after the confirmatory run.
# Output: results/posthoc/bd2024_scan.csv, bd2024_models.csv, bd2024_residuals.csv
source("scripts/lib_model.R")
dir.create(file.path(OUT, "posthoc"), showWarnings = FALSE)

D <- load_country("BD"); y <- D$y; months <- D$month; n <- length(y)
E <- eid_future("BD", months, VMAIN)
yt <- ts(y, start = D$start, frequency = 12)
Z <- select_interventions(y, E, months, "BD")            # the pre-specified rule (after the fix)
Zm <- int_matrix(Z, n)
ord <- select_orders(y, Zm, D$start)
cat("rule selects:", if (nrow(Z)) paste0(Z$type, Z$label, "[", Z$win, "]") else "none", " orders", ord_str(ord), "\n")
cval <- round(cval_default(n), 2)
idx <- function(m) match(as.Date(m), months)

## 1. Scan: t-statistic of AO / TC / LS added one at a time, Jan 2023 - Mar 2026,
##    (a) on the detection model of the rule (airline + Eid + rule-selected Z) and (b) on the primary orders.
scan <- NULL
for (m in seq(as.Date("2023-01-01"), as.Date("2026-03-01"), by = "month")) {
  i <- idx(m)
  for (tp in c("AO", "TC", "LS")) {
    x <- outlier_pattern(tp, i, n)
    fa <- safe_arima(yt, c(0, 1, 1), c(0, 1, 1), cbind(Zm, E, x))
    fp <- safe_arima(yt, ord$order, ord$seasonal, cbind(Zm, E, x), ord$drift, ord$mean)
    scan <- rbind(scan, data.frame(month = format(as.Date(m, origin = "1970-01-01"), "%Y-%m"), type = tp,
                                   t_airline = if (is.null(fa)) NA else unname(last_t(fa, 1)),
                                   t_primary = if (is.null(fp)) NA else unname(last_t(fp, 1)),
                                   coef_primary = if (is.null(fp)) NA else unname(tail(coef(fp), 1))))
  }
}
scan$cval <- cval
write.csv(scan, file.path(OUT, "posthoc", "bd2024_scan.csv"), row.names = FALSE)

## 2. Competing descriptions of 2024-25, all on the primary orders with the rule's Z and Eid terms
iJul <- idx("2024-07-01"); iAug <- idx("2024-08-01")
ramp <- function(from, to) { x <- numeric(n); x[from:n] <- pmin(seq_len(n - from + 1), to - from + 1); x }
trendchg <- function(from) { x <- numeric(n); x[from:n] <- seq_len(n - from + 1); x }
specs <- list(
  "none"                            = NULL,
  "LS Aug 2024"                     = cbind(LS = outlier_pattern("LS", iAug, n)),
  "AO Jul 2024"                     = cbind(AO = outlier_pattern("AO", iJul, n)),
  "AO Jul 2024 + LS Aug 2024"       = cbind(AO = outlier_pattern("AO", iJul, n), LS = outlier_pattern("LS", iAug, n)),
  "Ramp Aug 2024 - Mar 2025"        = cbind(RP = ramp(iAug, idx("2025-03-01"))),
  "Trend change from Aug 2024"      = cbind(TR = trendchg(iAug)))
mods <- NULL; fits <- list()
for (nm in names(specs)) {
  X <- cbind(Zm, specs[[nm]], E)
  f <- safe_arima(yt, ord$order, ord$seasonal, X, ord$drift, ord$mean); fits[[nm]] <- f
  cf <- coef(f); se <- sqrt(diag(f$var.coef)); k <- colnames(specs[[nm]])
  a <- f$arma; lb <- Box.test(residuals(f), lag = 24, type = "Ljung-Box", fitdf = sum(a[1:4]))
  mods <- rbind(mods, data.frame(model = nm, aicc = f$aicc, sigma2 = f$sigma2, LB24_p = lb$p.value,
    break_terms = if (length(k)) paste(sprintf("%s=%.3f (t %.2f)", k, cf[k], cf[k] / se[k]), collapse = "; ") else "",
    fitr = cf["Fitr"], fitr_se = se["Fitr"], adha = cf["Adha"], adha_se = se["Adha"]))
}
write.csv(mods, file.path(OUT, "posthoc", "bd2024_models.csv"), row.names = FALSE)

## 3. Residuals of the primary model around the break (systematic sign = unmodelled level change)
f0 <- fits[["none"]]; e <- as.numeric(residuals(f0))
res <- data.frame(month = format(months, "%Y-%m"), resid = e)
res <- res[months >= as.Date("2023-07-01"), ]
write.csv(res, file.path(OUT, "posthoc", "bd2024_residuals.csv"), row.names = FALSE)
w <- months >= as.Date("2024-08-01")
cat(sprintf("primary-model residuals: mean Aug 2024-Jun 2026 = %.4f (n=%d, t=%.2f); mean Jul 2022-Jul 2024 = %.4f\n",
            mean(e[w]), sum(w), mean(e[w]) / (sd(e[w]) / sqrt(sum(w))),
            mean(e[months >= as.Date("2022-07-01") & months < as.Date("2024-08-01")])))
print(mods[, 1:5], row.names = FALSE, digits = 4)
best <- scan[order(-abs(scan$t_airline)), ][1:8, ]; print(best, row.names = FALSE, digits = 3)
print(subset(scan, month %in% c("2024-07", "2024-08", "2024-09", "2024-10")), row.names = FALSE, digits = 3)
