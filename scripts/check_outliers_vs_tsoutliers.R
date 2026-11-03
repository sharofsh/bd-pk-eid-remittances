# Validation of scripts/lib_outliers.R against tsoutliers::tso 0.6-10 (run by Sharof in RStudio, 4 Nov 2026).
# Same inputs: log series, airline errors, fitr_w21 + adha_w21 as xreg, default cval. Run from repo root.
suppressMessages(library(forecast)); source("scripts/lib_outliers.R")
bd <- read.csv("data/bd_remittances_monthly.csv"); pk <- read.csv("data/pk_remittances_monthly.csv")
ex <- read.csv("data/eid_exposure_monthly.csv"); ex$month <- as.Date(ex$month)
prep <- function(df, dc, cc, s, e) { df$month <- as.Date(df[[dc]]); df <- df[df$month>=as.Date(s)&df$month<=as.Date(e),]
  df <- merge(df, ex[ex$country==cc,], by="month"); df <- df[order(df$month),]
  list(y=ts(log(df$remittances_usd_mn), start=as.numeric(format(min(df$month),c("%Y","%m"))), frequency=12),
       X=as.matrix(df[,c("fitr_w21","adha_w21")]), m=df$month) }
S <- list(BD=prep(bd,"calendar_date","BD","2009-07-01","2026-06-01"), PK=prep(pk,"date","PK","2005-07-01","2026-06-01"))
res <- NULL
for (cc in names(S)) { s <- S[[cc]]; r <- detect_outliers(s$y, s$X)
  cat(cc, "n =", length(s$y), "cval =", round(r$cval,3), "\n")
  if (nrow(r$outliers)) res <- rbind(res, data.frame(country=cc, month=format(s$m[r$outliers$ind],"%Y-%m"), type=r$outliers$type,
                                                     coefhat=round(r$outliers$coefhat,4), tstat=round(r$outliers$tstat,3))) }
ref <- read.csv("results/tsoutliers_check_fullsample.csv"); ref$coefhat <- round(ref$coefhat,4); ref$tstat <- round(ref$tstat,3)
cat("\n-- tsoutliers (Sharof, RStudio) --\n"); print(ref, row.names=FALSE)
cat("\n-- in-house --\n"); print(res, row.names=FALSE)
m <- merge(ref, res, by=c("country","month"), all=TRUE, suffixes=c(".tso",".own")); cat("\n-- merged --\n"); print(m, row.names=FALSE)
