suppressMessages({library(forecast)})
repo <- "/home/claude/bd-pk-eid-remittances"
out  <- "/home/claude/thesis_build/fig"
dir.create(out, showWarnings = FALSE)

bd <- read.csv(file.path(repo, "data/bd_remittances_monthly.csv"))
bd <- data.frame(date = as.Date(bd$calendar_date), y = bd$remittances_usd_mn)
pk <- read.csv(file.path(repo, "data/pk_remittances_monthly.csv"))
pk <- data.frame(date = as.Date(pk$date), y = pk$remittances_usd_mn)
bd <- subset(bd, date >= as.Date("2009-07-01") & date <= as.Date("2026-06-01"))
pk <- subset(pk, date >= as.Date("2005-07-01") & date <= as.Date("2026-06-01"))
ex <- read.csv(file.path(repo, "data/eid_exposure_monthly.csv"))
ex$month <- as.Date(ex$month)

# ---------- descriptive statistics ----------
desc <- function(d, nm) {
  g <- 100 * diff(log(d$y))
  data.frame(country = nm, n = nrow(d), start = format(min(d$date), "%b %Y"),
             end = format(max(d$date), "%b %Y"),
             mean = mean(d$y), sd = sd(d$y), min = min(d$y),
             min_month = format(d$date[which.min(d$y)], "%b %Y"),
             max = max(d$y), max_month = format(d$date[which.max(d$y)], "%b %Y"),
             mom_mean = mean(g), mom_sd = sd(g))
}
ds <- rbind(desc(bd, "BD"), desc(pk, "PK"))
write.csv(ds, file.path(out, "desc.csv"), row.names = FALSE)

# fiscal-year totals
fy <- function(d) { f <- as.integer(format(d$date, "%Y")) + (as.integer(format(d$date, "%m")) >= 7)
  a <- aggregate(d$y, list(fy = f), sum); a[table(f)[as.character(a$fy)] == 12, ] }
write.csv(merge(setNames(fy(bd), c("fy", "BD")), setNames(fy(pk), c("fy", "PK")), all = TRUE),
          file.path(out, "fy_totals.csv"), row.names = FALSE)

# Eid vs non-Eid months: ratio to centred 13-month MA (2x12)
ratio <- function(d, cc) {
  ma <- stats::filter(d$y, c(0.5, rep(1, 11), 0.5) / 12, sides = 2)
  r <- 100 * (d$y / ma - 1)
  e <- ex[ex$country == cc, ]
  e <- e[match(d$date, e$month), ]
  data.frame(date = d$date, r = r, fitr = e$fitr_w30, adha = e$adha_w30)
}
rb <- ratio(bd, "BD"); rp <- ratio(pk, "PK")
grp <- function(z) {
  z <- z[!is.na(z$r), ]
  tot <- z$fitr + z$adha
  c(full = mean(z$r[tot >= 0.5]), part = mean(z$r[tot > 0 & tot < 0.5]),
    none = mean(z$r[tot == 0]), n_full = sum(tot >= 0.5),
    n_part = sum(tot > 0 & tot < 0.5), n_none = sum(tot == 0))
}
write.csv(rbind(BD = grp(rb), PK = grp(rp)), file.path(out, "eid_ratio.csv"))

# ---------- Figure: series with Eid months ----------
png(file.path(out, "fig_series.png"), width = 2000, height = 1400, res = 220)
par(mfrow = c(2, 1), mar = c(3, 4.5, 2, 1), cex = 0.85)
plot_ser <- function(d, cc, ttl) {
  e <- ex[ex$country == cc, ]; e <- e[match(d$date, e$month), ]
  plot(d$date, d$y, type = "l", lwd = 1.3, col = "grey30", xlab = "", ylab = "US$ million",
       main = ttl, las = 1, xaxt = "n")
  axis.Date(1, at = seq(as.Date("2006-01-01"), as.Date("2026-01-01"), by = "2 years"), format = "%Y")
  f <- e$fitr_w30 >= 0.5; a <- e$adha_w30 >= 0.5
  points(d$date[f], d$y[f], pch = 19, col = "#1f77b4", cex = 0.8)
  points(d$date[a], d$y[a], pch = 17, col = "#d62728", cex = 0.8)
  legend("topleft", c("Month with >= half of Eid al-Fitr window", "Month with >= half of Eid al-Adha window"),
         pch = c(19, 17), col = c("#1f77b4", "#d62728"), bty = "n", cex = 0.85)
}
plot_ser(bd, "BD", "(a) Bangladesh, Jul 2009 - Jun 2026")
plot_ser(pk, "PK", "(b) Pakistan, Jul 2005 - Jun 2026")
dev.off()

# ---------- Figure: deviation from trend by Eid exposure ----------
png(file.path(out, "fig_ratio.png"), width = 2000, height = 900, res = 220)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 2, 1), cex = 0.85)
bx <- function(z, ttl) {
  z <- z[!is.na(z$r), ]; tot <- z$fitr + z$adha
  g <- factor(ifelse(tot == 0, "None", ifelse(tot < 0.5, "Under half", "Half or more")),
              levels = c("None", "Under half", "Half or more"))
  boxplot(z$r ~ g, col = c("grey85", "#c6dbef", "#6baed6"), las = 1, main = ttl,
          xlab = "Share of a 30-day pre-Eid window in the month", ylab = "% deviation from trend")
  abline(h = 0, lty = 2)
}
bx(rb, "(a) Bangladesh"); bx(rp, "(b) Pakistan")
dev.off()

# ---------- Figure: Eid al-Fitr date drift ----------
ed <- read.csv(file.path(repo, "data/eid_dates.csv"))
ed$eid_date <- as.Date(ed$eid_date)
e1 <- subset(ed, country == "BD" & eid_date >= as.Date("2005-07-01") & eid_date <= as.Date("2026-06-30"))
png(file.path(out, "fig_eid_dates.png"), width = 2000, height = 900, res = 220)
par(mar = c(4, 4.5, 1, 1), cex = 0.85)
doy <- as.integer(format(e1$eid_date, "%j"))
plot(e1$eid_date, doy, pch = ifelse(e1$event == "Fitr", 19, 17),
     col = ifelse(e1$event == "Fitr", "#1f77b4", "#d62728"), las = 1, yaxt = "n",
     xlab = "Year", ylab = "Calendar month of Eid")
axis(2, at = as.integer(format(as.Date(paste0("2021-", 1:12, "-15")), "%j")), labels = month.abb, las = 1)
legend("topright", c("Eid al-Fitr", "Eid al-Adha"), pch = c(19, 17), col = c("#1f77b4", "#d62728"), bty = "n")
dev.off()

# ---------- Figure: RMSE improvement by horizon ----------
tt <- read.csv(file.path(repo, "results_w30/eval_tests.csv"))
tt <- subset(tt, config == "primary")
png(file.path(out, "fig_rmse_h.png"), width = 2000, height = 1000, res = 220)
par(mar = c(4.5, 4.5, 1, 1), cex = 0.85)
m <- rbind(BD = tt$impr_RMSE_pct[tt$country == "BD"], PK = tt$impr_RMSE_pct[tt$country == "PK"])
sig <- rbind(tt$CW_p_one_sided[tt$country == "BD"] < 0.05, tt$CW_p_one_sided[tt$country == "PK"] < 0.05)
b <- barplot(m, beside = TRUE, names.arg = 1:12, col = c("#4c72b0", "#dd8452"), las = 1,
             xlab = "Forecast horizon h (months)", ylab = "RMSE improvement (%)",
             ylim = range(c(0, m)) * 1.15)
abline(h = 0)
text(b[sig], m[sig] + sign(m[sig]) * 0.5, "*", cex = 1.2)
legend("topright", c("Bangladesh", "Pakistan", "* Clark-West p < 0.05 (one-sided)"),
       fill = c("#4c72b0", "#dd8452", NA), border = c(1, 1, NA), bty = "n")
dev.off()
write.csv(tt[, c("country", "h", "n", "CW_t", "CW_p_one_sided", "DM_abs_p_two_sided", "impr_RMSE_pct")],
          file.path(out, "tests_by_h.csv"), row.names = FALSE)
cat("done\n")
