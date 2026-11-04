# Post hoc checks on the confirmatory forecast tests (NOT pre-specified; requested 4 Nov 2026).
#  (a) Clark-West / Diebold-Mariano with wider HAC lag choices (residual autocorrelation concern).
#  (b) July 2020: full-sample result next to the exploratory exclusion of Jul 2020 targets, and a
#      leave-one-target-month-out influence analysis. The primary analysis is NOT changed.
# Uses results/forecasts/<config>_<cc>.csv.  Output: results/posthoc/fc_hac.csv, fc_jul2020.csv, fc_loo.csv
suppressMessages(library(sandwich))
dir.create("results/posthoc", showWarnings = FALSE)
cfg <- Sys.getenv("CFG", "primary")

nw_var <- function(x, L) { x <- x - mean(x); T <- length(x); v <- sum(x^2) / T
  if (L > 0) for (j in 1:L) v <- v + 2 * (1 - j / (L + 1)) * sum(x[(j + 1):T] * x[1:(T - j)]) / T; v / T }
cw_series <- function(d) { eb <- d$actual - d$f_base; ee <- d$actual - d$f_eid; eb^2 - (ee^2 - (d$f_base - d$f_eid)^2) }
cw_t <- function(x, L) mean(x) / sqrt(nw_var(x, L))
holm <- function(p) p.adjust(p, "holm")

F <- lapply(c(BD = "BD", PK = "PK"), function(cc) read.csv(sprintf("results/forecasts/%s_%s.csv", cfg, cc)))
cells <- expand.grid(country = c("BD", "PK"), h = c(1, 3), stringsAsFactors = FALSE)

## (a) HAC choices
hac <- NULL
for (k in seq_len(nrow(cells))) {
  cc <- cells$country[k]; h <- cells$h[k]; d <- F[[cc]][F[[cc]]$h == h, ]
  x <- cw_series(d); m <- lm(x ~ 1)
  lbp <- Box.test(x, lag = 12, type = "Ljung-Box")$p.value
  se <- c("NW, h-1 lags (primary)" = sqrt(nw_var(x, h - 1)),
          "NW, 6 lags" = sqrt(nw_var(x, 6)), "NW, 12 lags" = sqrt(nw_var(x, 12)),
          "NW, automatic bandwidth" = sqrt(NeweyWest(m, prewhite = FALSE)[1, 1]),
          "NW, prewhitened automatic" = sqrt(NeweyWest(m, prewhite = TRUE)[1, 1]),
          "Andrews QS, prewhitened" = sqrt(kernHAC(m, prewhite = TRUE)[1, 1]))
  hac <- rbind(hac, data.frame(country = cc, h = h, n = length(x), cw_LB12_p = lbp, se_type = names(se),
                               CW_t = mean(x) / se, p_one_sided = 1 - pnorm(mean(x) / se)))
}
hac <- do.call(rbind, lapply(split(hac, hac$se_type), function(z) { z$holm_p <- holm(z$p_one_sided); z }))
write.csv(hac, "results/posthoc/fc_hac.csv", row.names = FALSE)

## (b) July 2020
jul <- NULL
for (k in seq_len(nrow(cells))) {
  cc <- cells$country[k]; h <- cells$h[k]; d <- F[[cc]][F[[cc]]$h == h, ]
  for (excl in c(FALSE, TRUE)) {
    dd <- if (excl) d[d$target != "2020-07", ] else d
    x <- cw_series(dd); eb <- dd$actual - dd$f_base; ee <- dd$actual - dd$f_eid
    jul <- rbind(jul, data.frame(analysis = if (excl) "EXPLORATORY: Jul 2020 target excluded" else "Full sample (primary)",
      country = cc, h = h, n = nrow(dd), CW_t = cw_t(x, h - 1), p_one_sided = 1 - pnorm(cw_t(x, h - 1)),
      impr_RMSE_pct = 100 * (1 - sqrt(mean(ee^2) / mean(eb^2)))))
  }
}
jul <- do.call(rbind, lapply(split(jul, jul$analysis), function(z) { z$holm_p <- holm(z$p_one_sided); z }))
write.csv(jul, "results/posthoc/fc_jul2020.csv", row.names = FALSE)

## leave-one-target-month-out
loo <- NULL
for (k in seq_len(nrow(cells))) {
  cc <- cells$country[k]; h <- cells$h[k]; d <- F[[cc]][F[[cc]]$h == h, ]
  for (tg in d$target) {
    dd <- d[d$target != tg, ]; x <- cw_series(dd); eb <- dd$actual - dd$f_base; ee <- dd$actual - dd$f_eid
    loo <- rbind(loo, data.frame(country = cc, h = h, dropped = tg, CW_t = cw_t(x, h - 1),
                                 impr_RMSE_pct = 100 * (1 - sqrt(mean(ee^2) / mean(eb^2)))))
  }
}
write.csv(loo, "results/posthoc/fc_loo.csv", row.names = FALSE)
sm <- do.call(rbind, lapply(split(loo, paste(loo$country, loo$h)), function(z) {
  i <- which.min(z$CW_t)
  data.frame(country = z$country[1], h = z$h[1], min_CW_t = z$CW_t[i], min_when_dropping = z$dropped[i],
             median_CW_t = median(z$CW_t), min_impr = min(z$impr_RMSE_pct), n_drops_t_below_1.645 = sum(z$CW_t < 1.645))
}))
write.csv(sm, "results/posthoc/fc_loo_summary.csv", row.names = FALSE)
print(hac, row.names = FALSE, digits = 3); print(jul, row.names = FALSE, digits = 3); print(sm, row.names = FALSE, digits = 3)
