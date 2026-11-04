# Analysis chronology and disclosure

This file records the order in which analyses were done, which design choices were informed by results already seen, and what changed after the confirmatory run. Times are Asia/Dhaka. Commit hashes refer to this repository.

## 1. Timeline

| When | What | Results seen at this point |
|---|---|---|
| Oct 2026 | **Bangladesh M.Sc. thesis (JU).** Same Bangladesh Bank series (Jul 2009 – Jun 2026). Phase 1 data; pre-specified plan v1.0, amended to v1.1 (confirmed 30 Oct 2026); one confirmatory run; then post hoc checks. | BD Eid effects and BD forecast comparisons. These include stronger forecast gains at short horizons and a pre/post Jul 2020 split. |
| Before 3 Nov 2026 | **Pakistan exploration.** In-sample Eid estimates; a paired airline-SARIMA forecast comparison; an outlier search. Sharof reported the search found "only a July 2016 level shift" and no COVID dip. | PK Eid estimates and a PK forecast comparison. |
| 3 Nov 2026 | Working design draft for the comparative study (`docs/design_draft_2026-11-03.md`). | As above |
| 4 Nov, 00:16 – 00:50 | Data and Eid dates committed (Phase 1; commits f27616f, 24d906e, 505d4e1, 16f9c10). | No new model results |
| **4 Nov, 00:53** | **Pre-specified plan v1.0 date-stamped (commit 683f560).** | No new model results |
| 4 Nov, 01:12 | In-house outlier detection validated against `tsoutliers::tso`, run by Sharof (f5fc2b8). | Full-sample automatic outliers (seen *after* 683f560; the plan was not changed) |
| 4 Nov, 01:17 – 02:32 | Confirmatory run 1 (c62ac69, PR #3). | All results |
| 4 Nov, ~05:55 | **Coding error found** in the intervention rule (deviation 2; see `DESIGN.md`). Fixed; every affected configuration rerun. | Results before and after the fix are both reported |
| 4 Nov, 05:53 onward | **Post hoc analyses requested by Sharof:** the Aug 2024 BD break; PK inference under residual autocorrelation; Jul 2020 influence. | These are labelled as not pre-specified wherever they appear |

## 2. Design choices informed by results already seen

| Choice in plan v1.0 | Informed by |
|---|---|
| 21-day window ending on Eid day | BD thesis (the same window was used there) |
| Focal horizons h = 1 and 3 | BD thesis: gains were stronger at short horizons. Labelled exploratory focal horizons in v1.0, not pre-specified. |
| Clark–West as the primary test; log-scale loss; expanding window as primary | BD thesis design |
| Stability split at Jul 2020 | BD thesis (start of FY21; COVID shift to formal channels) |
| PK candidate interventions: P3 (Jul 2016); no-COVID-dip claim | Sharof's PK outlier search. P4 (COVID) was still listed because it has an external reason, and the rule selects it. |
| BD candidate interventions B1–B5 | Narrative events known from the BD thesis period, some of which Sharof called "stories" |

## 3. What this means for interpretation

- **Bangladesh is not an independent confirmation of the thesis.** It uses the same data, the same author, and a design partly carried over from the thesis. It is a re-analysis under a stricter, pre-specified, two-country protocol.
- **Pakistan is a partial replication, not a blind one.** The design was informed by Bangladesh results, and some Pakistan results (in-sample Eid estimates, an airline-SARIMA forecast comparison, an outlier search) had been seen before the plan was fixed.
- **The strictly pre-specified elements** are those fixed in commit 683f560 before the confirmatory run: the intervention rule and candidate list, the order-selection procedure, the evaluation window, the Holm family, and the sensitivity list. Their execution is reproducible from the scripts.
- **Two kinds of change came after the plan**, and both are reported in full:
  - deviations caused by coding errors, which were fixed under `DESIGN.md` §10;
  - post hoc analyses, which are labelled as such.

## 4. Suggested wording for the paper (Methods, "Analysis plan and disclosure")

> The analysis plan, including the intervention rule, the candidate interventions, order selection, the forecast-evaluation design and the multiplicity correction, was fixed and date-stamped in a public repository (commit 683f560, 4 November 2026) before the confirmatory run. Several elements of the plan were informed by earlier work. A prior analysis of the same Bangladesh series (the first author's M.Sc. thesis) used the same 21-day Eid window and the same July 2020 stability split, and found larger forecast gains at short horizons; we therefore treat the focal horizons (1 and 3 months) as exploratory choices. Exploratory Pakistan analyses (in-sample Eid estimates, an airline-model forecast comparison and an outlier search) were also carried out before the plan was fixed. The Bangladesh results are therefore a re-analysis rather than an independent test, and the Pakistan results are a partial replication of a Bangladesh-informed design. Two coding errors found after the confirmatory run were corrected and all affected analyses rerun; results before and after the corrections are reported in the supplementary material. Analyses added after the confirmatory run are labelled post hoc.
