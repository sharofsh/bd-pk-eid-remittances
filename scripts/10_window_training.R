# Post hoc (11 Nov 2026): choose the Eid window on training data only (up to June 2017),
# so the forecast evaluation period (Jul 2017 - Jun 2026) plays no part in the choice.
# Decision rule fixed before running:
#   1. lowest AICc on the training data, separately per country;
#   2. if both countries agree, use that window;
#   3. if not, use the window with the lowest combined AICc difference across countries.
# Orders and interventions are selected on the training data exactly as at the first forecast origin.
Sys.setenv(EID_WINDOW = "30")
source("scripts/lib_model.R")

ed <- read.csv("data/eid_dates.csv"); ed$eid_date <- as.Date(ed$eid_date)
window_reg <- function(cc, months, w) {
  e <- ed[ed$country == cc, ]
  X <- matrix(0, length(months), 2, dimnames = list(NULL, c("Fitr", "Adha")))
  key <- format(months, "%Y-%m")
  for (k in seq_len(nrow(e))) {
    days <- seq(e$eid_date[k] - w + 1, e$eid_date[k], by = "day")
    tab <- table(format(days, "%Y-%m")) / w
    j <- match(names(tab), key); ok <- !is.na(j)
    col <- if (e$event[k] == "Fitr") 1 else 2
    X[j[ok], col] <- X[j[ok], col] + as.numeric(tab[ok])
  }
  X
}

ORIGIN <- as.Date("2017-06-01")
WINDOWS <- c(21, 30, 45, 60)
out <- NULL
for (cc in c("BD", "PK")) {
  d <- load_country(cc)
  # check the on-the-fly regressor against the stored 30-day column
  chk <- window_reg(cc, d$month, 30)
  stopifnot(max(abs(chk[, 1] - d$ex$fitr_w30)) < 1e-4, max(abs(chk[, 2] - d$ex$adha_w30)) < 1e-4)
  tr <- d$month <= ORIGIN
  y <- d$y[tr]; mo <- d$month[tr]
  for (w in WINDOWS) {
    E <- window_reg(cc, mo, w)
    Zs <- select_interventions(y, E, mo, cc)
    Z <- int_matrix(Zs, length(y))
    o <- select_orders(y, Z, d$start)
    yt <- ts(y, start = d$start, frequency = 12)
    fb <- safe_arima(yt, o$order, o$seasonal, Z, o$drift, o$mean)
    fe <- safe_arima(yt, o$order, o$seasonal, cbind(Z, E), o$drift, o$mean)
    out <- rbind(out, data.frame(country = cc, n_train = length(y), window = w, orders = ord_str(o),
                                 interventions = if (nrow(Zs)) paste0(Zs$type, Zs$label, collapse = " ") else "none",
                                 aicc_baseline = fb$aicc, aicc_eid = fe$aicc))
  }
}
# AICc is comparable across windows only if orders and interventions are the same
out$same_spec <- ave(paste(out$orders, out$interventions), out$country, FUN = function(v) length(unique(v)) == 1)
out$delta <- ave(out$aicc_eid, out$country, FUN = function(a) a - min(a))
dir.create("results_w30/posthoc", showWarnings = FALSE, recursive = TRUE)
write.csv(out, "results_w30/posthoc/window_choice_training.csv", row.names = FALSE)
print(out, digits = 5)
comb <- aggregate(delta ~ window, out, sum); print(comb)
