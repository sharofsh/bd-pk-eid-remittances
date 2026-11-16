Sys.setenv(EID_WINDOW="30"); source("scripts/lib_model.R"); suppressMessages(library(parallel))
src <- deparse(select_interventions); src <- gsub(">= 2", ">= 99", src, fixed=TRUE)
sel_nocap <- eval(parse(text=paste(src, collapse="\n")))
res <- NULL
for (cc in c("BD","PK")) { D <- load_country(cc); N <- length(D$y)
  origins <- which(D$month >= as.Date("2017-06-01") & seq_len(N) <= N-1)
  fc <- read.csv(sprintf("results_w30/forecasts/primary_%s.csv", cc)); fc <- fc[fc$h==1, c("origin","interventions")]
  r <- mclapply(origins, function(T) { months <- D$month[1:T]; y <- D$y[1:T]
    E <- eid_future(cc, months, VMAIN)[1:T,,drop=FALSE]
    b <- sel_nocap(y, E, months, cc)
    data.frame(country=cc, origin=format(D$month[T], "%Y-%m"), nocap=if (nrow(b)) paste(paste0(b$type,b$label), collapse="+") else "none")
  }, mc.cores=4)
  r <- merge(do.call(rbind, r), fc, by="origin", all.x=TRUE); res <- rbind(res, r) }
res$same <- res$nocap == res$interventions
write.csv(res, "/tmp/capall.csv", row.names=FALSE)
cat("origins:", nrow(res), " identical:", sum(res$same, na.rm=TRUE), " NA:", sum(is.na(res$same)), "\n"); print(res[!res$same | is.na(res$same), ])
