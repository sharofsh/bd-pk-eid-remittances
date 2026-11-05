# Forecast evaluation (DESIGN.md sections 7-9).
# Output: results/eval_accuracy.csv, results/eval_tests.csv, results/eval_primary_holm.csv,
#         results/eval_windows.csv, results/eval_periods.csv   (results_w30/ when EID_WINDOW=30)
EID_WINDOW <- as.integer(Sys.getenv("EID_WINDOW", "21"))
OUT <- if (EID_WINDOW == 21) "results" else paste0("results_w", EID_WINDOW)

nw_var <- function(x, L) {  # Newey-West long-run variance of the mean
  x <- x - mean(x); T <- length(x); v <- sum(x^2) / T
  if (L > 0) for (j in 1:L) v <- v + 2 * (1 - j / (L + 1)) * sum(x[(j + 1):T] * x[1:(T - j)]) / T
  v / T
}

files <- list.files(file.path(OUT, "forecasts"), pattern = "\\.csv$", full.names = TRUE)
F <- do.call(rbind, lapply(files, read.csv))
F <- F[!is.na(F$f_base) & !is.na(F$f_eid), ]
F$tdate <- as.Date(paste0(F$target, "-01"))

acc_one <- function(d) {
  e <- list(base = d$actual - d$f_base, eid = d$actual - d$f_eid, bj = d$actual - d$f_bj, snaive = d$actual - d$f_snaive)
  lev <- function(f) exp(d$actual) - exp(f)
  out <- NULL
  for (m in names(e)) {
    f <- switch(m, base = d$f_base, eid = d$f_eid, bj = d$f_bj, snaive = d$f_snaive)
    out <- rbind(out, data.frame(model = m, n = sum(!is.na(e[[m]])), MAE_log = mean(abs(e[[m]]), na.rm = TRUE),
      RMSE_log = sqrt(mean(e[[m]]^2, na.rm = TRUE)), ME_log = mean(e[[m]], na.rm = TRUE),
      MASE = mean(abs(e[[m]]) / d$mase_scale, na.rm = TRUE),
      MAE_usd = mean(abs(lev(f)), na.rm = TRUE), RMSE_usd = sqrt(mean(lev(f)^2, na.rm = TRUE)),
      MAPE = 100 * mean(abs(lev(f)) / exp(d$actual), na.rm = TRUE)))
  }
  out
}

tests_one <- function(d, h) {
  eb <- d$actual - d$f_base; ee <- d$actual - d$f_eid; T <- length(eb); L <- max(h - 1, 0)
  cw <- eb^2 - (ee^2 - (d$f_base - d$f_eid)^2)
  cw_t <- mean(cw) / sqrt(nw_var(cw, L))
  dm <- abs(eb) - abs(ee)
  dm_t <- mean(dm) / sqrt(nw_var(dm, L)) * sqrt((T + 1 - 2 * h + h * (h - 1) / T) / T)
  dsq <- eb^2 - ee^2
  data.frame(n = T, CW_t = cw_t, CW_p_one_sided = 1 - pnorm(cw_t),
             DM_abs_t = dm_t, DM_abs_p_two_sided = 2 * pt(-abs(dm_t), T - 1),
             dMSE = mean(dsq), dMSE_lo = mean(dsq) - 1.96 * sqrt(nw_var(dsq, L)), dMSE_hi = mean(dsq) + 1.96 * sqrt(nw_var(dsq, L)),
             dMAE = mean(dm), dMAE_lo = mean(dm) - 1.96 * sqrt(nw_var(dm, L)), dMAE_hi = mean(dm) + 1.96 * sqrt(nw_var(dm, L)),
             impr_RMSE_pct = 100 * (sqrt(mean(eb^2)) - sqrt(mean(ee^2))) / sqrt(mean(eb^2)),
             impr_MAE_pct = 100 * (mean(abs(eb)) - mean(abs(ee))) / mean(abs(eb)))
}

grid <- unique(F[, c("config", "country", "h")])
ACC <- NULL; TST <- NULL
for (i in seq_len(nrow(grid))) {
  g <- grid[i, ]; d <- F[F$config == g$config & F$country == g$country & F$h == g$h, ]
  ACC <- rbind(ACC, cbind(g, acc_one(d))); TST <- rbind(TST, cbind(g, tests_one(d, g$h)))
}
write.csv(ACC, file.path(OUT, "eval_accuracy.csv"), row.names = FALSE)
write.csv(TST, file.path(OUT, "eval_tests.csv"), row.names = FALSE)

## primary: Holm over BD/PK x h = 1, 3 (Clark-West)
P <- TST[TST$config == "primary" & TST$h %in% c(1, 3), ]
P$holm_p <- p.adjust(P$CW_p_one_sided, method = "holm")
P$reject_5pct <- P$holm_p < 0.05
write.csv(P, file.path(OUT, "eval_primary_holm.csv"), row.names = FALSE)

## training-window strategies on identical targets
W <- NULL
for (cc in unique(F$country)) for (h in c(1, 3, 6, 12)) {
  for (cfg in c("primary", "roll60", "roll96", "roll120")) {
    d <- F[F$config == cfg & F$country == cc & F$h == h, ]
    sub <- if (cfg == "roll120") "targets from Jul 2019 (origin >= Jun 2019)" else "all targets"
    if (cfg == "roll120") d <- d[d$origin >= "2019-06", ]
    if (!nrow(d)) next
    W <- rbind(W, cbind(data.frame(country = cc, h = h, strategy = cfg, target_set = sub),
                        acc_one(d)[1:2, c("model", "n", "RMSE_log", "MAE_log")], tests_one(d, h)[, c("CW_t", "CW_p_one_sided", "impr_RMSE_pct")]))
  }
  d <- F[F$config == "primary" & F$country == cc & F$h == h & F$origin >= "2019-06", ]
  W <- rbind(W, cbind(data.frame(country = cc, h = h, strategy = "primary", target_set = "targets from Jul 2019 (origin >= Jun 2019)"),
                      acc_one(d)[1:2, c("model", "n", "RMSE_log", "MAE_log")], tests_one(d, h)[, c("CW_t", "CW_p_one_sided", "impr_RMSE_pct")]))
}
write.csv(W, file.path(OUT, "eval_windows.csv"), row.names = FALSE)

## later-period errors: targets before vs from Jul 2020
PER <- NULL
for (cfg in c("primary", "roll60", "roll96")) for (cc in unique(F$country)) for (h in c(1, 3)) {
  for (per in c("pre", "post")) {
    d <- F[F$config == cfg & F$country == cc & F$h == h, ]
    d <- if (per == "pre") d[d$tdate < as.Date("2020-07-01"), ] else d[d$tdate >= as.Date("2020-07-01"), ]
    if (nrow(d) < 10) next
    PER <- rbind(PER, cbind(data.frame(config = cfg, country = cc, h = h, period = per),
                            acc_one(d)[1:2, c("model", "n", "RMSE_log", "MAE_log")], tests_one(d, h)[, c("CW_t", "impr_RMSE_pct")]))
  }
}
write.csv(PER, file.path(OUT, "eval_periods.csv"), row.names = FALSE)
cat("evaluation done:", length(files), "forecast files\n")
