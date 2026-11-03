# RQ1: full-sample Eid effects, cross-country test, temporal stability (DESIGN.md section 6),
# plus the same estimates under sensitivities S1-S6 and S10.
# Output: results/rq1_effects.csv, results/rq1_crosscountry.csv, results/rq1_stability.csv,
#         results/rq1_diagnostics.csv, results/rq1_residual_acf_<cc>.png
source("scripts/lib_model.R")

jarque_bera <- function(e) { e <- e[is.finite(e)]; n <- length(e); m <- e - mean(e)
  s <- mean(m^3) / mean(m^2)^1.5; k <- mean(m^4) / mean(m^2)^2
  jb <- n / 6 * (s^2 + (k - 3)^2 / 4); c(JB = jb, p = 1 - pchisq(jb, 2)) }

fit_full <- function(cc, span = SPANS[[cc]], variant = "w21", rule = "cand", orders = "auto") {
  D <- load_country(cc, span); y <- D$y; months <- D$month; n <- length(y)
  E <- eid_future(cc, months, variant)
  Z <- switch(rule, cand = select_interventions(y, E, months, cc), auto = select_auto(y, E, months),
              none = data.frame(ind = integer(0), type = character(0), win = character(0), t = numeric(0), label = character(0)))
  Zm <- int_matrix(Z, n)
  ord <- if (orders == "airline") AIRLINE else select_orders(y, Zm, D$start)
  yt <- ts(y, start = D$start, frequency = 12)
  fe <- safe_arima(yt, ord$order, ord$seasonal, cbind(Zm, E), ord$drift, ord$mean)
  list(D = D, E = E, Z = Z, Zm = Zm, ord = ord, fit = fe, yt = yt)
}

effects_row <- function(r, label) {
  cf <- coef(r$fit); se <- sqrt(diag(r$fit$var.coef))
  do.call(rbind, lapply(c("Fitr", "Adha"), function(v) {
    b <- cf[v]; s <- se[v]
    data.frame(spec = label, country = r$D$country, span = paste(format(range(r$D$month), "%Y-%m"), collapse = " to "),
               n = length(r$D$y), eid = v, beta = unname(b), se = unname(s),
               pct = 100 * (exp(b) - 1), pct_lo = 100 * (exp(b - 1.96 * s) - 1), pct_hi = 100 * (exp(b + 1.96 * s) - 1),
               p = 2 * pnorm(-abs(b / s)), orders = ord_str(r$ord),
               interventions = if (nrow(r$Z)) paste(paste0(r$Z$type, r$Z$label, "[", r$Z$win, "]"), collapse = " ") else "none")
  }))
}

specs <- list(primary = list(), S1_w10 = list(variant = "w10"), S1_w30 = list(variant = "w30"),
              S2_pre = list(variant = "w21_pre"), S3_uq = list(variant = "w21_uq"),
              S4_airline = list(orders = "airline"), S5_none = list(rule = "none"), S6_auto = list(rule = "auto"))
fits <- list(); eff <- NULL
for (nm in names(specs)) for (cc in c("BD", "PK")) {
  r <- do.call(fit_full, c(list(cc = cc), specs[[nm]]))
  fits[[paste(nm, cc)]] <- r; eff <- rbind(eff, effects_row(r, nm))
  cat(nm, cc, ord_str(r$ord), "\n")
}
# S9: PK span to Sep 2026; S10: common window
r <- fit_full("PK", span = SPANS_S9$PK); eff <- rbind(eff, effects_row(r, "S9_pk_sep26"))
cw <- c("2009-07-01", "2026-06-01")
r10 <- list(BD = fits[["primary BD"]], PK = fit_full("PK", span = cw))
eff <- rbind(eff, effects_row(r10$PK, "S10_common_window"))
write.csv(eff, "results/rq1_effects.csv", row.names = FALSE)

## diagnostics (primary)
diag <- NULL
for (cc in c("BD", "PK")) {
  r <- fits[[paste("primary", cc)]]; e <- residuals(r$fit); a <- r$fit$arma
  lb <- Box.test(e, lag = 24, type = "Ljung-Box", fitdf = sum(a[1:4]))
  jb <- jarque_bera(as.numeric(e))
  diag <- rbind(diag, data.frame(country = cc, orders = ord_str(r$ord), LB24 = lb$statistic, LB24_df = lb$parameter,
                                 LB24_p = lb$p.value, JB = jb["JB"], JB_p = jb["p"], sigma2 = r$fit$sigma2, aicc = r$fit$aicc))
  png(sprintf("results/rq1_residual_acf_%s.png", cc), 1200, 500, res = 120)
  par(mfrow = c(1, 2)); acf(e, 36, main = paste(cc, "residual ACF")); pacf(e, 36, main = paste(cc, "residual PACF")); dev.off()
}
write.csv(diag, "results/rq1_diagnostics.csv", row.names = FALSE)

## cross-country test
cross <- NULL
for (v in c("Fitr", "Adha")) {
  g <- function(r) c(coef(r$fit)[v], sqrt(diag(r$fit$var.coef))[v])
  a <- g(fits[["primary BD"]]); b <- g(fits[["primary PK"]])
  z <- (a[1] - b[1]) / sqrt(a[2]^2 + b[2]^2)
  cross <- rbind(cross, data.frame(test = "primary (full spans, independent)", eid = v, diff = a[1] - b[1],
                                   se = sqrt(a[2]^2 + b[2]^2), z = z, p = 2 * pnorm(-abs(z)), rho = NA))
  # S10: common window, rho-adjusted
  eb <- residuals(r10$BD$fit); ep <- residuals(r10$PK$fit)
  rho <- cor(as.numeric(eb), as.numeric(ep))
  a <- g(r10$BD); b <- g(r10$PK)
  s <- sqrt(a[2]^2 + b[2]^2 - 2 * rho * a[2] * b[2]); z <- (a[1] - b[1]) / s
  cross <- rbind(cross, data.frame(test = "S10 common window, rho-adjusted", eid = v, diff = a[1] - b[1],
                                   se = s, z = z, p = 2 * pnorm(-abs(z)), rho = rho))
}
write.csv(cross, "results/rq1_crosscountry.csv", row.names = FALSE)

## temporal stability: Eid x Post (Post = Jul 2020 onward), same orders and interventions
stab <- NULL
for (cc in c("BD", "PK")) {
  r <- fits[[paste("primary", cc)]]
  post <- as.numeric(r$D$month >= as.Date("2020-07-01"))
  X <- cbind(r$Zm, r$E, FitrPost = r$E[, "Fitr"] * post, AdhaPost = r$E[, "Adha"] * post)
  f <- safe_arima(r$yt, r$ord$order, r$ord$seasonal, X, r$ord$drift, r$ord$mean)
  cf <- coef(f); V <- f$var.coef; k <- c("FitrPost", "AdhaPost")
  W <- as.numeric(t(cf[k]) %*% solve(V[k, k]) %*% cf[k])
  stab <- rbind(stab, data.frame(country = cc, term = c("Fitr (pre)", "Adha (pre)", "Fitr x Post", "Adha x Post"),
                                 beta = cf[c("Fitr", "Adha", k)], se = sqrt(diag(V))[c("Fitr", "Adha", k)],
                                 wald_chi2_2 = W, wald_p = 1 - pchisq(W, 2)))
}
write.csv(stab, "results/rq1_stability.csv", row.names = FALSE)
cat("RQ1 done\n")
