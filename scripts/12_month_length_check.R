# Sensitivity: add a month-length regressor (log days in month) to the main RegARIMA; same orders and interventions.
Sys.setenv(EID_WINDOW = Sys.getenv("EID_WINDOW", "30")); source("scripts/lib_model.R")
src <- readLines("scripts/03_rq1_estimation.R"); eval(parse(text = src[grep("^fit_full", src):(grep("^effects_row", src) - 1)]))
out <- NULL
for (cc in c("BD", "PK")) {
  r <- fit_full(cc)
  m <- r$D$month; dim <- as.numeric(format(seq(m[1], by = "month", length.out = length(m) + 1)[-1] - 1, "%d"))
  ml <- log(dim) - mean(log(dim))
  X0 <- cbind(r$Zm, r$E); X1 <- cbind(X0, MonthLen = ml)
  f1 <- safe_arima(r$yt, r$ord$order, r$ord$seasonal, X1, r$ord$drift, r$ord$mean)
  for (nm in c("base", "monthlen")) {
    f <- if (nm == "base") r$fit else f1; cf <- coef(f); se <- sqrt(diag(f$var.coef))
    out <- rbind(out, data.frame(country = cc, model = nm, aicc = round(f$aicc, 2),
      fitr_pct = round(100 * (exp(cf["Fitr"]) - 1), 1), adha_pct = round(100 * (exp(cf["Adha"]) - 1), 1),
      monthlen_coef = if (nm == "monthlen") round(cf["MonthLen"], 3) else NA,
      monthlen_p = if (nm == "monthlen") signif(2 * pnorm(-abs(cf["MonthLen"] / se["MonthLen"])), 3) else NA))
  }
}
write.csv(out, "results_w30/posthoc/month_length_check.csv", row.names = FALSE); print(out, row.names = FALSE)
