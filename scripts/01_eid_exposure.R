# Monthly Eid exposure regressors.
#
# Exposure of month m to an event = share of the event window's days that fall in m.
# Window of L days ending on Eid day (inclusive): Eid-(L-1), ..., Eid.
# Primary: L = 21. Sensitivity: L = 10, 30; and L = 21 ending the day before Eid ("_pre").
# Separate regressors for Eid al-Fitr and Eid al-Adha.
# "_uq" columns use the Umm al-Qura date for every event (sensitivity: local vs Umm al-Qura).
#
# Input : data/eid_dates.csv
# Output: data/eid_exposure_monthly.csv  (one row per country-month over each country's data span)
# Run from repo root: Rscript scripts/01_eid_exposure.R

dates <- read.csv("data/eid_dates.csv", stringsAsFactors = FALSE)
dates$eid_date    <- as.Date(dates$eid_date)
dates$umm_al_qura <- as.Date(dates$umm_al_qura)

span <- list(BD = c(as.Date("2009-07-01"), as.Date("2026-07-01")),
             PK = c(as.Date("2005-07-01"), as.Date("2026-09-01")))

month_start <- function(d) as.Date(format(d, "%Y-%m-01"))

# exposure of each month in `months` to windows ending at `ends` (offset = days before end)
exposure <- function(ends, months, L, offset = 0) {
  out <- setNames(numeric(length(months)), as.character(months))
  for (i in seq_along(ends)) {
    last <- ends[i] - offset
    days <- seq(last - (L - 1), last, by = "day")
    tab  <- table(as.character(month_start(days)))
    hit  <- intersect(names(tab), names(out))
    out[hit] <- out[hit] + as.numeric(tab[hit]) / L
  }
  unname(out)
}

specs <- list(w21 = c(21, 0), w10 = c(10, 0), w30 = c(30, 0), w21_pre = c(21, 1))

rows <- list()
for (cc in names(span)) {
  months <- seq(span[[cc]][1], span[[cc]][2], by = "month")
  df <- data.frame(country = cc, month = months)
  for (ev in c("Fitr", "Adha")) {
    d <- dates[dates$country == cc & dates$event == ev, ]
    for (nm in names(specs)) {
      df[[paste0(tolower(ev), "_", nm)]] <- exposure(d$eid_date, months, specs[[nm]][1], specs[[nm]][2])
    }
    df[[paste0(tolower(ev), "_w21_uq")]] <- exposure(d$umm_al_qura, months, 21, 0)
  }
  rows[[cc]] <- df
}
expo <- do.call(rbind, rows)

## ---- checks ---------------------------------------------------------------
xcols <- setdiff(names(expo), c("country", "month"))
stopifnot(all(expo[xcols] >= 0), all(expo[xcols] <= 1 + 1e-12))
# Fitr and Adha windows never overlap (events are ~70 days apart), so a month's
# combined 30-day exposure cannot exceed 1
stopifnot(all(expo$fitr_w30 + expo$adha_w30 <= 1 + 1e-12))
# every event whose whole window lies inside the span contributes exactly 1
for (cc in names(span)) {
  for (ev in c("Fitr", "Adha")) {
    d <- dates[dates$country == cc & dates$event == ev, ]
    full <- d$eid_date - 29 >= span[[cc]][1] & d$eid_date <= span[[cc]][2] + 30
    total <- sum(expo[expo$country == cc, paste0(tolower(ev), "_w30")])
    partial <- !full & d$in_sample == 1
    stopifnot(total >= sum(full) - 1e-9, total <= sum(full) + sum(partial) + 1e-9)
  }
}

expo$month <- format(expo$month, "%Y-%m-%d")
expo[xcols] <- lapply(expo[xcols], round, 6)
write.csv(expo, "data/eid_exposure_monthly.csv", row.names = FALSE)
cat("wrote data/eid_exposure_monthly.csv:", nrow(expo), "rows\n")
print(aggregate(cbind(fitr_w21, adha_w21) ~ country, data = expo, FUN = function(x) sum(x > 0)))
