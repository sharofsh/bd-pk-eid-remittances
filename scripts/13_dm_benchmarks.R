# Diebold-Mariano tests (HLN correction) of the model with Eid regressors against the Box-Jenkins and seasonal naive benchmarks, h = 1 and 3; Holm over the 4 tests for each benchmark. PW=2 squared log error (reported), PW=1 absolute error.
suppressMessages(library(forecast)); PW <- as.numeric(Sys.getenv("PW","2"))
out <- NULL
for (cc in c("BD","PK")) { d <- read.csv(sprintf("results_w30/forecasts/primary_%s.csv", cc))
  for (h in c(1,3)) { x <- d[d$h==h & !is.na(d$f_eid) & !is.na(d$f_bj),]; e2 <- x$actual-x$f_eid
    for (b in c("f_bj","f_snaive")) { e1 <- x$actual-x[[b]]
      t2 <- dm.test(e1,e2,h=h,power=PW,alternative="two.sided"); t1 <- dm.test(e1,e2,h=h,power=PW,alternative="greater")
      out <- rbind(out, data.frame(country=cc,h=h,benchmark=sub("f_","",b),n=nrow(x),
        rmse_bench=sqrt(mean(e1^2)), rmse_eid=sqrt(mean(e2^2)), impr=100*(1-sqrt(mean(e2^2))/sqrt(mean(e1^2))),
        DM=unname(t2$statistic), p_two=t2$p.value, p_one=t1$p.value)) } } }
out$p_one_holm <- ave(out$p_one, out$benchmark, FUN=function(p) p.adjust(p,"holm"))
out[,5:11] <- round(out[,5:11],4); print(out, row.names=FALSE)
write.csv(out,sprintf("results_w30/posthoc/dm_vs_benchmarks_power%d.csv",PW),row.names=FALSE)
