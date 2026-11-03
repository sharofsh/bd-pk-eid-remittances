# Rolling-origin forecasts (DESIGN.md sections 7-9).
# Usage: Rscript scripts/04_forecast_run.R <config> <country>
# Configs: primary, roll60, roll96, roll120, S1_w10, S1_w30, S2_pre, S3_uq, S4_airline, S5_none, S6_auto, S9_pk_sep26
# Output: results/forecasts/<config>_<country>.csv ; per-origin selection log in the same row set.
source("scripts/lib_model.R")
suppressMessages(library(parallel))
args <- commandArgs(TRUE); config <- args[1]; cc <- args[2]
CFG <- list(
  primary    = list(win = Inf, variant = "w21",     rule = "cand", orders = "auto"),
  roll60     = list(win = 60,  variant = "w21",     rule = "cand", orders = "auto"),
  roll96     = list(win = 96,  variant = "w21",     rule = "cand", orders = "auto"),
  roll120    = list(win = 120, variant = "w21",     rule = "cand", orders = "auto", first = as.Date("2019-06-01")),
  S1_w10     = list(win = Inf, variant = "w10",     rule = "cand", orders = "auto"),
  S1_w30     = list(win = Inf, variant = "w30",     rule = "cand", orders = "auto"),
  S2_pre     = list(win = Inf, variant = "w21_pre", rule = "cand", orders = "auto"),
  S3_uq      = list(win = Inf, variant = "w21_uq",  rule = "cand", orders = "auto"),
  S4_airline = list(win = Inf, variant = "w21",     rule = "cand", orders = "airline"),
  S5_none    = list(win = Inf, variant = "w21",     rule = "none", orders = "auto"),
  S6_auto    = list(win = Inf, variant = "w21",     rule = "auto", orders = "auto"),
  S9_pk_sep26= list(win = Inf, variant = "w21",     rule = "cand", orders = "auto", span = SPANS_S9$PK))
cfg <- CFG[[config]]; stopifnot(!is.null(cfg))
H <- 12
D <- load_country(cc, if (!is.null(cfg$span)) cfg$span else SPANS[[cc]])
N <- length(D$y)
first_origin <- if (!is.null(cfg$first)) cfg$first else as.Date("2017-06-01")
origins <- which(D$month >= first_origin & seq_len(N) <= N - 1)
if (nzchar(Sys.getenv("TEST_ORIGINS"))) origins <- origins[as.integer(strsplit(Sys.getenv("TEST_ORIGINS"), ",")[[1]])]
bj <- read.csv("results/benchmark_orders.csv"); bj <- bj[bj$country == cc, ]
bj_order <- as.integer(strsplit(bj$order, ",")[[1]]); bj_seas <- as.integer(strsplit(bj$seasonal, ",")[[1]])
dir.create("results/cache", showWarnings = FALSE); dir.create("results/forecasts", showWarnings = FALSE)

cached <- function(key, expr) {
  key <- gsub("[^A-Za-z0-9_.-]", "_", key)
  # Deviation 2026-11-04: long keys (many automatic outliers in S6) exceeded the 255-byte filename limit.
  if (nchar(key) > 120) key <- paste0(substr(key, 1, 80), "_", digest::digest(key, algo = "md5"))
  f <- file.path("results/cache", paste0(key, ".rds"))
  if (file.exists(f)) return(readRDS(f))
  v <- expr; saveRDS(v, f); v
}

one_origin <- function(T) {
  s <- if (is.finite(cfg$win)) max(1, T - cfg$win + 1) else 1
  tr <- s:T; months <- D$month[tr]; y <- D$y[tr]; n <- length(tr)
  fut_months <- seq(D$month[T], by = "month", length.out = H + 1)[-1]
  Eall <- eid_future(cc, c(months, fut_months), cfg$variant)
  E <- Eall[1:n, , drop = FALSE]; Ef <- Eall[n + 1:H, , drop = FALSE]
  tkey <- sprintf("%s_%s_%s", cc, format(months[1], "%Y%m"), format(months[n], "%Y%m"))
  Z <- switch(cfg$rule,
    cand = cached(paste0("int_cand_", cfg$variant, "_", tkey), select_interventions(y, E, months, cc)),
    auto = cached(paste0("int_auto_", cfg$variant, "_", tkey), select_auto(y, E, months)),
    none = data.frame(ind = integer(0), type = character(0), win = character(0), t = numeric(0), label = character(0)))
  Zall <- int_matrix(Z, n + H); Ztr <- if (is.null(Zall)) NULL else Zall[1:n, , drop = FALSE]
  Zf <- if (is.null(Zall)) NULL else Zall[n + 1:H, , drop = FALSE]
  zsig <- if (nrow(Z)) paste(paste0(Z$type, Z$label), collapse = "+") else "none"
  ord <- if (cfg$orders == "airline") AIRLINE else
    cached(paste0("ord_", tkey, "_", zsig), select_orders(y, Ztr, as.numeric(format(months[1], c("%Y", "%m")))))
  yt <- ts(y, start = as.numeric(format(months[1], c("%Y", "%m"))), frequency = 12)
  fb <- safe_arima(yt, ord$order, ord$seasonal, Ztr, ord$drift, ord$mean)
  fe <- safe_arima(yt, ord$order, ord$seasonal, cbind(Ztr, E), ord$drift, ord$mean)
  fbj <- safe_arima(yt, bj_order, bj_seas, NULL)
  pb <- if (is.null(fb)) rep(NA, H) else as.numeric(forecast(fb, h = H, xreg = Zf)$mean)
  pe <- if (is.null(fe)) rep(NA, H) else as.numeric(forecast(fe, h = H, xreg = cbind(Zf, Ef))$mean)
  pbj <- if (is.null(fbj)) rep(NA, H) else as.numeric(forecast(fbj, h = H)$mean)
  psn <- vapply(1:H, function(h) y[n - 12 + ((h - 1) %% 12) + 1], 0)
  scale <- mean(abs(diff(y, lag = 12)))
  tgt <- T + 1:H
  data.frame(config = config, country = cc, origin = format(D$month[T], "%Y-%m"), n_train = n, h = 1:H,
             target = format(fut_months, "%Y-%m"),
             actual = ifelse(tgt <= N, D$y[pmin(tgt, N)], NA),
             f_base = pb, f_eid = pe, f_bj = pbj, f_snaive = psn, mase_scale = scale,
             orders = ord_str(ord), interventions = zsig,
             b_fitr = if (is.null(fe)) NA else unname(coef(fe)["Fitr"]),
             b_adha = if (is.null(fe)) NA else unname(coef(fe)["Adha"]),
             fail = is.null(fb) || is.null(fe))
}

t0 <- Sys.time()
res <- mclapply(origins, function(T) tryCatch(one_origin(T), error = function(e) {
  message("origin ", format(D$month[T]), ": ", conditionMessage(e)); NULL }), mc.cores = 2)
res <- do.call(rbind, res)
res <- res[!is.na(res$actual), ]
write.csv(res, sprintf("results/forecasts/%s_%s.csv", config, cc), row.names = FALSE)
n_err <- length(origins) - length(unique(res$origin))   # origins dropped by an R error (deviation 2026-11-04)
cat(sprintf("%s %s: %d origins, %d rows, %d failed origins (%d model failures, %d errors), %.1f min\n", config, cc,
            length(origins), nrow(res), sum(res$fail[res$h == 1]) + n_err, sum(res$fail[res$h == 1]), n_err,
            as.numeric(difftime(Sys.time(), t0, units = "mins"))))
