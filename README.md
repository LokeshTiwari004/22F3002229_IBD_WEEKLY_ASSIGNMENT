# IBD WEEK 4 ASSIGNMENTS

Dataproc PySpark pipeline for click-count binning by hour.

## Files and Utilities

| File | Utility |
|---|---|
| `.env` | Project, bucket, prefix, and cluster configuration |
| `bootstrap.sh` | Enables APIs, uploads scripts, and creates the Dataproc cluster |
| `submit_jobs.sh` | Uploads input data and submits RDD and DataFrame PySpark jobs |
| `wrapup.sh` | Downloads outputs and deletes the cluster |
| `scripts/click_counts_rdd.py` | RDD-based click counting by hour bin |
| `scripts/click_counts_df.py` | DataFrame-based click counting by hour bin |
| `input/click_file.txt` | Sample click-event input |
| `output/` | Local destination for fetched job outputs |
| `VIDEO_SCRIPT.md` | Screencast narration |

## Pipeline Workflow

1. Configure `.env`.
2. Run `./bootstrap.sh`.
3. Run `./submit_jobs.sh`.
4. Run `./wrapup.sh`.

## Sample Input/Output Pair

Input:

```text
user_id,timestamp
u001,2025-08-01 09:03:23
u012,2025-08-01 12:37:50
```

Outputs:

```text
output/click_file.rdd/
output/click_file.df/
```
