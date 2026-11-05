# Run the whole analysis with a chosen main Eid window.
#
# In RStudio: open the project folder (working directory = repo root), set the two lines below,
# then click Source (or run source("scripts/run_analysis.R")).
#
#   WINDOW = "21"  -> the pre-specified primary analysis, written to results/
#   WINDOW = "30"  -> the same pipeline with a 30-day main window (post hoc, 5 Nov 2026),
#                     written to results_w30/ (results/ is not touched)
#
#   SCOPE = "core" -> RQ1 + the expanding-window forecasts + evaluation  (about 1-2 h on Windows)
#   SCOPE = "full" -> also rolling windows and sensitivities S1-S6, S9    (several hours on Windows)
#
# From a terminal instead: Rscript scripts/run_analysis.R 30 core

WINDOW <- "30"
SCOPE  <- "core"

args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1) WINDOW <- args[1]
if (length(args) >= 2) SCOPE  <- args[2]
stopifnot(WINDOW %in% c("21", "30"), SCOPE %in% c("core", "full"))

need <- c("forecast", "sandwich", "lmtest", "digest")
miss <- need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
if (length(miss)) install.packages(miss)

if (!file.exists("scripts/lib_model.R")) stop("Set the working directory to the repository root first.")
Sys.setenv(EID_WINDOW = WINDOW)
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
run <- function(...) {
  a <- c(...); cat("\n==>", a, format(Sys.time(), "(%H:%M)"), "\n")
  if (system2(rscript, a) != 0) stop("Step failed: ", paste(a, collapse = " "))
}

out <- if (WINDOW == "21") "results" else paste0("results_w", WINDOW)
s1  <- if (WINDOW == "21") c("S1_w10", "S1_w30") else c("S1_w21", "S1_w45")
cfgs <- if (SCOPE == "core") "primary" else
  c("primary", "roll60", "roll96", "roll120", s1, "S2_pre", "S3_uq", "S4_airline", "S5_none", "S6_auto")

run("scripts/01_eid_exposure.R")                                   # Eid regressors (all windows)
if (!file.exists("results/benchmark_orders.csv")) run("scripts/02_identify_sarima_benchmark.R")
run("scripts/03_rq1_estimation.R")                                 # RQ1: effects, cross-country, stability
for (cfg in cfgs) for (cc in c("BD", "PK")) run("scripts/04_forecast_run.R", cfg, cc)
if (SCOPE == "full") run("scripts/04_forecast_run.R", "S9_pk_sep26", "PK")
run("scripts/05_evaluate.R")                                       # RQ2: accuracy and tests

if (WINDOW != "21") writeLines(c(
  sprintf("Main Eid window = %s days. POST HOC (5 Nov 2026): not the pre-specified analysis.", WINDOW),
  "The pre-specified primary (21 days) is in results/. Same code, interventions rule, orders rule and tests."),
  file.path(out, "README.txt"))

cat("\nDone. Results in", out, "\n")
cat("Key files: rq1_effects.csv, rq1_crosscountry.csv, rq1_stability.csv, rq1_diagnostics.csv,\n",
    "          eval_primary_holm.csv (Clark-West + Holm), eval_tests.csv, eval_accuracy.csv\n")
print(read.csv(file.path(out, "eval_primary_holm.csv"))[, c("country", "h", "CW_t", "holm_p", "impr_RMSE_pct")])
