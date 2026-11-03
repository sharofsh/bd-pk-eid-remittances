# In-house outlier detection (Chen & Liu 1993), written to mirror tsoutliers::tso
# (types AO, TC(delta = 0.7), LS; locate on residuals, then drop jointly non-significant).
# Used because tsoutliers cannot be installed in the analysis environment.

cval_default <- function(n) if (n <= 50) 3 else if (n >= 450) 4 else 3 + 0.0025 * (n - 50)

poly_mult <- function(a, b) { out <- rep(0, length(a) + length(b) - 1)
  for (i in seq_along(a)) out[i:(i + length(b) - 1)] <- out[i:(i + length(b) - 1)] + a[i] * b; out }

# pi weights of the full (differenced) error model, length n
pi_weights <- function(fit, n) {
  a <- fit$arma  # p, q, P, Q, s, d, D
  co <- fit$coef
  p <- a[1]; q <- a[2]; P <- a[3]; Q <- a[4]; s <- a[5]; d <- a[6]; D <- a[7]
  phi   <- if (p) co[paste0("ar", 1:p)] else numeric(0)
  theta <- if (q) co[paste0("ma", 1:q)] else numeric(0)
  Phi   <- if (P) co[paste0("sar", 1:P)] else numeric(0)
  Theta <- if (Q) co[paste0("sma", 1:Q)] else numeric(0)
  seas <- function(v, s) { out <- c(1, rep(0, s * length(v))); for (k in seq_along(v)) out[1 + s * k] <- v[k]; out }
  AR <- poly_mult(c(1, -phi), seas(-Phi, s))
  for (i in seq_len(d)) AR <- poly_mult(AR, c(1, -1))
  for (i in seq_len(D)) AR <- poly_mult(AR, c(1, rep(0, s - 1), -1))
  MA <- poly_mult(c(1, theta), seas(Theta, s))
  AR <- c(AR, rep(0, n))[1:n]; MA <- c(MA, rep(0, n))[1:n]
  # pi = AR / MA  (power series division)
  pw <- numeric(n)
  for (k in 1:n) pw[k] <- AR[k] - if (k > 1) sum(MA[2:k] * pw[(k - 1):1]) else 0
  pw
}

outlier_pattern <- function(type, t0, n, delta = 0.7) {
  x <- numeric(n)
  if (type == "AO") x[t0] <- 1
  if (type == "LS") x[t0:n] <- 1
  if (type == "TC") x[t0:n] <- delta^(0:(n - t0))
  x
}

fit_model <- function(y, xreg, order, seasonal) {
  stats::arima(y, order = order, seasonal = list(order = seasonal), xreg = xreg)
}

# coefficient and t-statistic for every (month, type) on residuals e
tstats_all <- function(e, pw, types, delta) {
  n <- length(e)
  sig <- 1.483 * median(abs(e - median(e)))
  out <- NULL
  for (t0 in 1:n) for (ty in types) {
    xi <- outlier_pattern(ty, t0, n, delta)
    xc <- vapply(1:n, function(t) sum(pw[1:t] * xi[t:1]), 0)
    sxx <- sum(xc^2); w <- sum(e * xc) / sxx
    out <- rbind(out, data.frame(ind = t0, type = ty, coefhat = w, tau = w / (sig / sqrt(sxx))))
  }
  out
}

# among same-type outliers in consecutive months keep only the largest |tau|
drop_consecutive <- function(mo) {
  if (is.null(mo) || nrow(mo) < 2) return(mo)
  keep <- rep(TRUE, nrow(mo))
  for (ty in unique(mo$type)) {
    idx <- which(mo$type == ty); idx <- idx[order(mo$ind[idx])]
    if (length(idx) < 2) next
    run <- cumsum(c(1, diff(mo$ind[idx]) != 1))
    for (r in unique(run)) { g <- idx[run == r]
      if (length(g) > 1) keep[g[-which.max(abs(mo$tau[g]))]] <- FALSE }
  }
  mo[keep, , drop = FALSE]
}

locate_one <- function(e, pw, cval, types, delta) {
  st <- tstats_all(e, pw, types, delta)
  mo <- st[abs(st$tau) > cval, , drop = FALSE]
  if (!nrow(mo)) return(mo)
  mo <- mo[order(-abs(mo$tau)), ]; mo <- mo[!duplicated(mo$ind), ]
  drop_consecutive(mo)
}

resid_effect <- function(mo, pw, n, delta) rowSums(matrix(sapply(seq_len(nrow(mo)), function(i) {
  xi <- outlier_pattern(mo$type[i], mo$ind[i], n, delta)
  mo$coefhat[i] * vapply(1:n, function(t) sum(pw[1:t] * xi[t:1]), 0) }), nrow = n))

# Chen-Liu procedure with the same stages and defaults as tsoutliers::tso(tsmethod = "arima"):
# outer loop (refit on the outlier-adjusted series) around an inner loop (locate on residuals,
# remove their effect, locate again); then en-masse discarding on a joint fit with the
# original series, repeated until every remaining outlier has |t| >= cval.
detect_outliers <- function(y, xreg, order = c(0, 1, 1), seasonal = c(0, 1, 1),
                            types = c("AO", "LS", "TC"), delta = 0.7,
                            cval = round(cval_default(length(y)), 2),
                            maxit.iloop = 4, maxit.oloop = 4) {
  n <- length(y); ya <- y
  fit <- fit_model(ya, xreg, order, seasonal)
  moall <- NULL
  for (o in 1:maxit.oloop) {
    pw <- pi_weights(fit, n); e <- as.numeric(residuals(fit))
    mo_it <- NULL
    for (i in 1:maxit.iloop) {
      mo <- locate_one(e, pw, cval, types, delta)
      if (!is.null(mo_it)) mo <- mo[!mo$ind %in% mo_it$ind, , drop = FALSE]
      if (!nrow(mo)) break
      mo_it <- rbind(mo_it, mo)
      e <- e - resid_effect(mo, pw, n, delta)
    }
    if (is.null(mo_it)) break
    mo_it <- drop_consecutive(mo_it)
    if (!is.null(moall)) mo_it <- mo_it[!mo_it$ind %in% moall$ind, , drop = FALSE]
    if (!nrow(mo_it)) break
    moall <- rbind(moall, mo_it)
    ya <- ya - rowSums(matrix(sapply(seq_len(nrow(mo_it)), function(i)
      mo_it$coefhat[i] * outlier_pattern(mo_it$type[i], mo_it$ind[i], n, delta)), nrow = n))
    fit <- fit_model(ya, xreg, order, seasonal)
  }
  found <- if (is.null(moall)) data.frame(ind = integer(0), type = character(0), tau = numeric(0)) else
    drop_consecutive(moall)[, c("ind", "type", "tau")]
  mk <- function(f) matrix(sapply(seq_len(nrow(f)), function(i) outlier_pattern(f$type[i], f$ind[i], n, delta)), nrow = n)
  discarded <- integer(0)
  while (nrow(found)) {
    fit <- fit_model(y, cbind(xreg, mk(found)), order, seasonal)
    cf <- coef(fit); se <- sqrt(diag(fit$var.coef)); idx <- (length(cf) - nrow(found) + 1):length(cf)
    tt <- cf[idx] / se[idx]
    drop <- abs(tt) < cval
    if (!any(drop)) { found$coefhat <- cf[idx]; found$tstat <- tt; break }
    discarded <- c(discarded, found$ind[drop]); found <- found[!drop, , drop = FALSE]
  }
  if (!nrow(found)) fit <- fit_model(y, xreg, order, seasonal)
  list(outliers = found[order(found$ind), setdiff(names(found), "tau"), drop = FALSE],
       fit = fit, cval = cval, discarded = sort(discarded))
}
