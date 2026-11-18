# Rolling-origin forecast check with X-13ARIMA-SEATS (not part of the thesis analysis).
# Run in RStudio from the repository root after scripts/15 works (needs library(seasonal)).
#
# At each of the 108 origins (Jun 2017 to May 2026) X-13 is refitted on the data to that
# month with its automatic settings (automdl, AO/LS/TC outlier search, trading-day test),
# once WITH and once WITHOUT the Eid regressors, and forecasts 1 and 3 months ahead.
# Its errors are compared with the thesis model with Eid regressors
# (results_w30/forecasts/primary_XX.csv). Expect roughly 5-10 minutes.

library(seasonal)
suppressMessages(library(forecast))   # for dm.test

ex <- read.csv("data/eid_exposure_monthly.csv")
info <- list(BD = list(file = "data/bd_remittances_monthly.csv", start = c(2009, 7)),
             PK = list(file = "data/pk_remittances_monthly.csv", start = c(2005, 7)))
H <- c(1, 3)

fit_fc <- function(y, xreg) {
  args <- list(x = y, transform.function = "log", regression.aictest = "td",
               outlier.types = c("ao", "ls", "tc"), forecast.maxlead = max(H), forecast.save = "fct", x11 = "")
  if (!is.null(xreg)) { args$xreg <- xreg; args$regression.usertype <- "holiday" }
  m <- try(do.call(seas, args), silent = TRUE)
  if (inherits(m, "try-error")) { message(substr(m, 1, 200)); return(rep(NA, max(H))) }
  fc <- m$series$fct
  if (is.null(fc)) return(rep(NA, max(H)))
  log(as.numeric(fc[1:max(H), 1]))
}

res <- NULL
for (cc in names(info)) {
  s <- info[[cc]]
  d <- read.csv(s$file)
  yall <- window(ts(d$remittances_usd_mn, start = s$start, frequency = 12), end = c(2026, 6))
  e <- ex[ex$country == cc, ]; e <- e[order(e$month), ]
  first <- which(substr(e$month, 1, 7) == sprintf("%d-%02d", s$start[1], s$start[2]))
  X <- as.matrix(e[first:nrow(e), c("fitr_w30", "adha_w30")])
  xall <- ts(X, start = s$start, frequency = 12)

  pr <- read.csv(sprintf("results_w30/forecasts/primary_%s.csv", cc))
  origins <- unique(pr$origin)
  for (o in origins) {
    yo <- as.integer(substr(o, 1, 4)); mo <- as.integer(substr(o, 6, 7))
    y <- window(yall, end = c(yo, mo))
    xr <- window(xall, end = c(yo + 2, mo))          # Eid dates are known ahead
    f_e <- fit_fc(y, xr); f_n <- fit_fc(y, NULL)
    for (h in H) {
      p <- pr[pr$origin == o & pr$h == h, ]
      if (nrow(p) == 1)
        res <- rbind(res, data.frame(country = cc, origin = o, h = h, actual = p$actual,
                                     f_thesis = p$f_eid, f_x13_eid = f_e[h], f_x13_noeid = f_n[h]))
    }
    cat(cc, o, "\r")
  }
}
write.csv(res, "results_w30/posthoc/x13_forecast_check.csv", row.names = FALSE)

rmse <- function(e) sqrt(mean(e^2, na.rm = TRUE))
cat("\n\nLog RMSE (lower is better); DM = one-sided HLN test that the thesis model is more accurate\n")
for (cc in names(info)) for (h in H) {
  r <- na.omit(res[res$country == cc & res$h == h, ])
  e0 <- r$actual - r$f_thesis; e1 <- r$actual - r$f_x13_eid; e2 <- r$actual - r$f_x13_noeid
  dm1 <- dm.test(e1, e0, h = h, power = 2, alternative = "greater")$p.value
  cat(sprintf("%s h=%d  n=%d | thesis %.3f | X-13+Eid %.3f (DM p=%.3f) | X-13 no Eid %.3f | Eid gain inside X-13 %.1f%%\n",
              cc, h, nrow(r), rmse(e0), rmse(e1), dm1, rmse(e2), 100 * (1 - rmse(e1) / rmse(e2))))
}
