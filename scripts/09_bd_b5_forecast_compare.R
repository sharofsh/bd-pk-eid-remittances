# Post hoc (4 Nov 2026): does adding the Aug 2024 BD break change the forecasting results, especially at long horizons?
# Compares primary vs X_B5_LS vs X_B5_AO_LS on (a) all targets and (b) targets from origins where the break has entered.
EID_WINDOW <- as.integer(Sys.getenv("EID_WINDOW", "21")); OUT <- if (EID_WINDOW == 21) "results" else paste0("results_w", EID_WINDOW)
nw_var <- function(x, L) { x <- x - mean(x); T <- length(x); v <- sum(x^2) / T
  if (L > 0) for (j in 1:L) v <- v + 2 * (1 - j / (L + 1)) * sum(x[(j + 1):T] * x[1:(T - j)]) / T; v / T }
cfgs <- c("primary", "X_B5_LS", "X_B5_AO_LS")
F <- lapply(setNames(cfgs, cfgs), function(c) read.csv(file.path(OUT, "forecasts", sprintf("%s_BD.csv", c))))
out <- NULL
for (subset in c("all targets", "origins >= Nov 2024")) for (h in c(1, 3, 6, 9, 12)) for (c in cfgs) {
  d <- F[[c]]; d <- d[d$h == h, ]
  if (subset != "all targets") d <- d[d$origin >= "2024-11", ]
  eb <- d$actual - d$f_base; ee <- d$actual - d$f_eid; x <- eb^2 - (ee^2 - (d$f_base - d$f_eid)^2)
  out <- rbind(out, data.frame(subset = subset, h = h, config = c, n = nrow(d),
    ME_base = mean(eb), ME_eid = mean(ee), RMSE_base = sqrt(mean(eb^2)), RMSE_eid = sqrt(mean(ee^2)),
    impr_RMSE_pct = 100 * (1 - sqrt(mean(ee^2) / mean(eb^2))),
    CW_t = if (nrow(d) > h + 5) mean(x) / sqrt(nw_var(x, h - 1)) else NA))
}
dir.create(file.path(OUT, "posthoc"), showWarnings = FALSE)
write.csv(out, file.path(OUT, "posthoc", "bd2024_forecast_compare.csv"), row.names = FALSE)
print(out, row.names = FALSE, digits = 3)
