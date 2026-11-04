# Post hoc reassessment of inference under the PK residual autocorrelation (lags 13, 14, 35).
# NOT pre-specified; requested by Sharof on 4 Nov 2026. BD is run through the same code for comparison.
# Output: results/posthoc/pk_inference_models.csv, pk_inference_hac.csv, pk_inference_cross.csv
source("scripts/lib_model.R")
suppressMessages(library(sandwich))
dir.create("results/posthoc", showWarnings = FALSE)

prep <- function(cc) {
  D <- load_country(cc); y <- D$y; months <- D$month; n <- length(y)
  E <- eid_future(cc, months, "w21")
  Z <- select_interventions(y, E, months, cc); Zm <- int_matrix(Z, n)
  ord <- select_orders(y, Zm, D$start)
  list(D = D, E = E, Z = Z, Zm = Zm, ord = ord, yt = ts(y, start = D$start, frequency = 12), n = n)
}
lb <- function(f, L) {  # fitdf = number of estimated (not fixed) ARMA parameters
  k <- sum(f$arma[1:4]); est <- if (!is.null(f$mask)) sum(f$mask[seq_len(k)]) else k
  Box.test(residuals(f), lag = L, type = "Ljung-Box", fitdf = est)$p.value }

## 1. Alternative error models: does whitening the residuals change the Eid SEs?
alt_models <- function(P) {
  o <- P$ord
  specs <- list(
    primary = list(order = o$order, seasonal = o$seasonal, drift = o$drift, fixed = NULL),
    "(0,1,1)(1,0,1)+drift" = list(order = c(0, 1, 1), seasonal = c(1, 0, 1), drift = TRUE, fixed = NULL),
    "(0,1,1)(2,0,0)+drift" = list(order = c(0, 1, 1), seasonal = c(2, 0, 0), drift = TRUE, fixed = NULL),
    "(0,1,1)(0,1,1) airline" = list(order = c(0, 1, 1), seasonal = c(0, 1, 1), drift = FALSE, fixed = NULL),
    "(2,1,2)(1,0,1)+drift" = list(order = c(2, 1, 2), seasonal = c(1, 0, 1), drift = TRUE, fixed = NULL),
    # subset MA at lags 1, 13, 14 on top of the primary seasonal part
    "subset MA{1,13,14} + primary seasonal" = list(order = c(0, 1, 14), seasonal = o$seasonal, drift = o$drift,
                                                   sub = c(1, 13, 14)))
  out <- NULL
  for (nm in names(specs)) {
    s <- specs[[nm]]; X <- cbind(P$Zm, P$E)
    f <- if (is.null(s$sub)) safe_arima(P$yt, s$order, s$seasonal, X, s$drift, FALSE) else {
      q <- s$order[3]; np <- q + sum(s$seasonal[c(1, 3)]) + s$drift + ncol(X)
      fx <- rep(NA_real_, np); fx[setdiff(1:q, s$sub)] <- 0
      tryCatch(Arima(P$yt, order = s$order, seasonal = s$seasonal, xreg = X, include.drift = s$drift,
                     fixed = fx, transform.pars = FALSE, method = "ML"), error = function(e) NULL) }
    if (is.null(f)) next
    cf <- coef(f); se <- sqrt(diag(f$var.coef))
    out <- rbind(out, data.frame(country = P$D$country, model = nm, aicc = f$aicc,
      LB12_p = lb(f, 12), LB24_p = lb(f, 24), LB36_p = lb(f, 36),
      fitr = cf["Fitr"], fitr_se = se["Fitr"], adha = cf["Adha"], adha_se = se["Adha"]))
  }
  out
}

## 2. HAC inference on the whitened (GLS-transformed) regression.
## Filter y and every regressor through the estimated ARIMA error filter (innovations with all ARMA
## parameters fixed at the primary estimates), regress filtered y on filtered X by OLS (this reproduces
## the GLS / ML point estimates up to start-up effects), then use HAC standard errors that allow any
## remaining residual autocorrelation.
hac_whitened <- function(P) {
  f <- safe_arima(P$yt, P$ord$order, P$ord$seasonal, cbind(P$Zm, P$E), P$ord$drift, P$ord$mean)
  arma <- coef(f)[grep("^(ar|ma|sar|sma)[0-9]", names(coef(f)))]
  filt <- function(z) {
    z <- ts(as.numeric(z), start = start(P$yt), frequency = 12)
    g <- Arima(z, order = P$ord$order, seasonal = P$ord$seasonal, include.mean = FALSE,
               fixed = arma, transform.pars = FALSE)
    as.numeric(residuals(g))
  }
  X <- cbind(P$Zm, P$E)
  if (P$ord$drift) X <- cbind(X, drift = seq_len(P$n))
  if (P$ord$mean) X <- cbind(X, intercept = 1)
  yf <- filt(P$yt); Xf <- apply(X, 2, filt)
  keep <- -(1:(sum(P$ord$order[2], 12 * P$ord$seasonal[2]) + 1))       # drop start-up observations
  m <- lm(yf[keep] ~ Xf[keep, ] - 1); names(m$coefficients) <- colnames(X)
  b <- coef(m)[c("Fitr", "Adha")]
  V <- list(
    "model-based (ML)"              = f$var.coef[c("Fitr", "Adha"), c("Fitr", "Adha")],
    "OLS on whitened"               = vcov(m)[c("Fitr", "Adha"), c("Fitr", "Adha")],
    "NW, automatic bandwidth"       = NeweyWest(m, prewhite = FALSE)[c("Fitr", "Adha"), c("Fitr", "Adha")],
    "NW, prewhitened"               = NeweyWest(m, prewhite = TRUE)[c("Fitr", "Adha"), c("Fitr", "Adha")],
    "NW, 36 lags"                   = NeweyWest(m, lag = 36, prewhite = FALSE)[c("Fitr", "Adha"), c("Fitr", "Adha")],
    "Andrews QS kernel"             = kernHAC(m, prewhite = TRUE)[c("Fitr", "Adha"), c("Fitr", "Adha")])
  out <- NULL
  for (nm in names(V)) {
    bb <- if (nm == "model-based (ML)") coef(f)[c("Fitr", "Adha")] else b
    se <- sqrt(diag(V[[nm]]))
    out <- rbind(out, data.frame(country = P$D$country, se_type = nm, fitr = bb[1], fitr_se = se[1],
                                 adha = bb[2], adha_se = se[2], fitr_p = 2 * pnorm(-abs(bb[1] / se[1])),
                                 adha_p = 2 * pnorm(-abs(bb[2] / se[2]))))
  }
  out
}

## 3. Moving-block bootstrap of the whitened-regression residuals (block length 24), as a check on HAC.
block_boot <- function(P, B = 999, L = 24, seed = 20261104) {
  f <- safe_arima(P$yt, P$ord$order, P$ord$seasonal, cbind(P$Zm, P$E), P$ord$drift, P$ord$mean)
  arma <- coef(f)[grep("^(ar|ma|sar|sma)[0-9]", names(coef(f)))]
  filt <- function(z) { z <- ts(as.numeric(z), start = start(P$yt), frequency = 12)
    as.numeric(residuals(Arima(z, order = P$ord$order, seasonal = P$ord$seasonal, include.mean = FALSE,
                               fixed = arma, transform.pars = FALSE))) }
  X <- cbind(P$Zm, P$E); if (P$ord$drift) X <- cbind(X, drift = seq_len(P$n))
  keep <- -(1:(P$ord$order[2] + 12 * P$ord$seasonal[2] + 1))
  yf <- filt(P$yt)[keep]; Xf <- apply(X, 2, filt)[keep, , drop = FALSE]
  m <- lm(yf ~ Xf - 1); e <- residuals(m); fit <- fitted(m); T <- length(e)
  j <- match(c("Fitr", "Adha"), colnames(X))
  set.seed(seed)
  bs <- t(replicate(B, {
    st <- sample.int(T - L + 1, ceiling(T / L), replace = TRUE)
    eb <- unlist(lapply(st, function(s) e[s:(s + L - 1)]))[1:T]
    coef(lm((fit + eb) ~ Xf - 1))[j]
  }))
  data.frame(country = P$D$country, se_type = sprintf("moving-block bootstrap (L=%d, B=%d)", L, B),
             fitr = coef(m)[j[1]], fitr_se = sd(bs[, 1]), adha = coef(m)[j[2]], adha_se = sd(bs[, 2]),
             fitr_p = 2 * pnorm(-abs(coef(m)[j[1]] / sd(bs[, 1]))), adha_p = 2 * pnorm(-abs(coef(m)[j[2]] / sd(bs[, 2]))))
}

P <- list(BD = prep("BD"), PK = prep("PK"))
alt <- rbind(alt_models(P$BD), alt_models(P$PK))
hac <- rbind(hac_whitened(P$BD), block_boot(P$BD), hac_whitened(P$PK), block_boot(P$PK))
write.csv(alt, "results/posthoc/pk_inference_models.csv", row.names = FALSE)
write.csv(hac, "results/posthoc/pk_inference_hac.csv", row.names = FALSE)

## 4. Cross-country test with each SE type (independent samples, as in the primary test)
cross <- NULL
for (st in unique(hac$se_type)) {
  a <- hac[hac$country == "BD" & hac$se_type == st, ]; b <- hac[hac$country == "PK" & hac$se_type == st, ]
  for (v in c("fitr", "adha")) {
    d <- a[[v]] - b[[v]]; s <- sqrt(a[[paste0(v, "_se")]]^2 + b[[paste0(v, "_se")]]^2)
    cross <- rbind(cross, data.frame(se_type = st, eid = v, diff = d, se = s, p = 2 * pnorm(-abs(d / s))))
  }
}
# worst case for PK: largest PK SE across all SE types and alternative models, BD model-based
pk_max <- c(fitr = max(c(hac$fitr_se[hac$country == "PK"], alt$fitr_se[alt$country == "PK"])),
            adha = max(c(hac$adha_se[hac$country == "PK"], alt$adha_se[alt$country == "PK"])))
write.csv(cross, "results/posthoc/pk_inference_cross.csv", row.names = FALSE)
print(alt, row.names = FALSE, digits = 3); print(hac, row.names = FALSE, digits = 3); print(cross, row.names = FALSE, digits = 3)
cat("largest PK SE seen: Fitr", round(pk_max["fitr"], 4), " Adha", round(pk_max["adha"], 4), "\n")
