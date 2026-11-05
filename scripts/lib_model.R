# Shared model code for the confirmatory run (DESIGN.md v1.0, sections 2-5).
# Run all scripts from the repo root.

suppressMessages(library(forecast))
source("scripts/lib_outliers.R")

## ---- data ------------------------------------------------------------------
SPANS <- list(BD = c("2009-07-01", "2026-06-01"),
              PK = c("2005-07-01", "2026-06-01"))
SPANS_S9 <- list(PK = c("2005-07-01", "2026-09-01"))

load_country <- function(cc, span = SPANS[[cc]]) {
  raw <- if (cc == "BD") {
    d <- read.csv("data/bd_remittances_monthly.csv"); data.frame(month = as.Date(d$calendar_date), v = d$remittances_usd_mn)
  } else {
    d <- read.csv("data/pk_remittances_monthly.csv"); data.frame(month = as.Date(d$date), v = d$remittances_usd_mn)
  }
  raw <- raw[raw$month >= as.Date(span[1]) & raw$month <= as.Date(span[2]), ]
  ex <- read.csv("data/eid_exposure_monthly.csv"); ex$month <- as.Date(ex$month)
  ex <- ex[ex$country == cc, ]
  d <- merge(raw, ex, by = "month"); d <- d[order(d$month), ]
  stopifnot(nrow(d) == nrow(raw), !anyNA(d$v))
  list(country = cc, month = d$month, y = log(d$v), ex = d,
       start = as.numeric(format(d$month[1], c("%Y", "%m"))))
}

# Eid regressors for a variant; also needs exposure beyond the sample for forecasting
eid_cols <- list(w21 = c("fitr_w21", "adha_w21"), w10 = c("fitr_w10", "adha_w10"),
                 w30 = c("fitr_w30", "adha_w30"), w21_pre = c("fitr_w21_pre", "adha_w21_pre"),
                 w21_uq = c("fitr_w21_uq", "adha_w21_uq"),
                 w45 = c("fitr_w45", "adha_w45"), w30_pre = c("fitr_w30_pre", "adha_w30_pre"),
                 w30_uq = c("fitr_w30_uq", "adha_w30_uq"))

## ---- main Eid window ---------------------------------------------------------
## Default 21 days = the pre-specified primary (DESIGN.md v1.0), written to results/.
## EID_WINDOW=30 runs the same pipeline with a 30-day main window (post hoc, 5 Nov 2026),
## written to results_w30/. S1 then uses 21 and 45 days; S2/S3 use the 30-day _pre/_uq variants.
EID_WINDOW <- as.integer(Sys.getenv("EID_WINDOW", "21"))
stopifnot(EID_WINDOW %in% c(21, 30))
VMAIN  <- paste0("w", EID_WINDOW)
S1_ALT <- if (EID_WINDOW == 21) c("w10", "w30") else c("w21", "w45")
OUT    <- if (EID_WINDOW == 21) "results" else paste0("results_w", EID_WINDOW)
dir.create(file.path(OUT, "forecasts"), recursive = TRUE, showWarnings = FALSE)
eid_future <- function(cc, months, variant) {
  ex <- read.csv("data/eid_exposure_monthly.csv"); ex$month <- as.Date(ex$month)
  ex <- ex[ex$country == cc, ]
  m <- match(months, ex$month)
  X <- as.matrix(ex[m, eid_cols[[variant]]]); colnames(X) <- c("Fitr", "Adha")
  # months beyond the exposure file (only possible past Sep 2026) have no Eid window
  X[is.na(X)] <- 0
  X
}

## ---- candidate interventions (DESIGN.md section 5) -----------------------------
CANDIDATES <- data.frame(
  id      = c("B1", "B2", "B3", "B4", "B5", "P1", "P2", "P3", "P4", "P5", "P6"),
  country = c(rep("BD", 5), rep("PK", 6)),
  from    = as.Date(c("2019-07-01", "2020-03-01", "2022-01-01", "2022-09-01", "2024-08-01",
                      "2008-10-01", "2009-04-01", "2016-07-01", "2020-03-01", "2022-09-01", "2023-09-01")),
  to      = as.Date(c("2019-07-01", "2020-07-01", "2022-01-01", "2022-09-01", "2024-10-01",
                      "2009-01-01", "2009-06-01", "2016-07-01", "2020-07-01", "2022-09-01", "2023-09-01")),
  stringsAsFactors = FALSE)

# regressor matrix for interventions over N periods (training + horizon)
int_matrix <- function(Zdf, N) {
  if (is.null(Zdf) || !nrow(Zdf)) return(NULL)
  M <- sapply(seq_len(nrow(Zdf)), function(i) outlier_pattern(Zdf$type[i], Zdf$ind[i], N, 0.7))
  M <- matrix(M, nrow = N); colnames(M) <- paste0(Zdf$type, "_", Zdf$label); M
}

safe_arima <- function(y, order, seasonal, xreg, drift = FALSE, mean = FALSE) {
  for (m in c("CSS-ML", "ML", "CSS")) {
    f <- tryCatch(Arima(y, order = order, seasonal = seasonal, xreg = xreg,
                        include.drift = drift, include.mean = mean, method = m),
                  error = function(e) NULL)
    if (!is.null(f) && all(is.finite(diag(f$var.coef)))) return(f)
  }
  NULL
}

last_t <- function(fit, k) { cf <- coef(fit); se <- sqrt(diag(fit$var.coef)); j <- (length(cf) - k + 1):length(cf); cf[j] / se[j] }

# Rule of section 5: candidates only, detected on the model WITH Eid regressors (airline errors),
# >= 3 post-event observations in the window, forward selection by largest |t| >= cval(n),
# at most 2 interventions per candidate window.
select_interventions <- function(y, E, months, cc, cval = round(cval_default(length(y)), 2)) {
  T <- length(y)
  # Deviation 2026-11-04 (coding error): y must carry frequency 12, otherwise Arima() silently drops the
  # seasonal part of the airline model. Before this fix the candidate tests ran on a non-seasonal ARIMA(0,1,1).
  y <- ts(as.numeric(y), frequency = 12)
  cand <- CANDIDATES[CANDIDATES$country == cc, ]
  elig <- NULL
  for (i in seq_len(nrow(cand))) {
    ms <- seq(cand$from[i], cand$to[i], by = "month")
    idx <- match(ms, months); idx <- idx[!is.na(idx) & idx <= T - 3]
    if (length(idx)) elig <- rbind(elig, expand.grid(ind = idx, type = c("AO", "TC", "LS"),
                                                     win = cand$id[i], stringsAsFactors = FALSE))
  }
  sel <- data.frame(ind = integer(0), type = character(0), win = character(0), t = numeric(0))
  if (is.null(elig)) return(sel)
  repeat {
    left <- elig[!elig$ind %in% sel$ind & !elig$win %in% names(which(table(sel$win) >= 2)), ]
    if (!nrow(left)) break
    Zs <- if (nrow(sel)) sapply(seq_len(nrow(sel)), function(i) outlier_pattern(sel$type[i], sel$ind[i], T)) else NULL
    tt <- vapply(seq_len(nrow(left)), function(j) {
      x <- outlier_pattern(left$type[j], left$ind[j], T)
      f <- safe_arima(y, c(0, 1, 1), c(0, 1, 1), cbind(E, Zs, x))
      if (is.null(f)) NA_real_ else unname(last_t(f, 1))
    }, 0)
    if (all(is.na(tt)) || max(abs(tt), na.rm = TRUE) < cval) break
    j <- which.max(abs(tt))
    sel <- rbind(sel, data.frame(ind = left$ind[j], type = left$type[j], win = left$win[j], t = tt[j]))
  }
  sel$label <- if (nrow(sel)) format(months[sel$ind], "%Y%m") else character(0)
  sel[order(sel$ind), ]
}

# S6: fully automatic detection (tso-equivalent) on the model with Eid regressors
select_auto <- function(y, E, months) {
  r <- detect_outliers(ts(y, frequency = 12), E)
  o <- r$outliers
  if (!nrow(o)) return(data.frame(ind = integer(0), type = character(0), win = character(0), t = numeric(0), label = character(0)))
  data.frame(ind = o$ind, type = o$type, win = "auto", t = o$tstat, label = format(months[o$ind], "%Y%m"))
}

# Orders on the baseline given Z (section 4)
select_orders <- function(y, Z, start) {
  yt <- ts(y, start = start, frequency = 12)
  f <- auto.arima(yt, xreg = Z, stepwise = FALSE, approximation = FALSE,
                  max.p = 3, max.q = 3, max.P = 1, max.Q = 1, ic = "aicc",
                  allowdrift = TRUE, allowmean = TRUE, test = "kpss")
  a <- f$arma
  list(order = a[c(1, 6, 2)], seasonal = a[c(3, 7, 4)],
       drift = "drift" %in% names(coef(f)), mean = "intercept" %in% names(coef(f)))
}
AIRLINE <- list(order = c(0, 1, 1), seasonal = c(0, 1, 1), drift = FALSE, mean = FALSE)

ord_str <- function(o) sprintf("(%s)(%s)%s", paste(o$order, collapse = ","), paste(o$seasonal, collapse = ","),
                               if (o$drift) "+drift" else if (o$mean) "+mean" else "")
