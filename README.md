# IBD Weekly Assignment — GCS Text Processor

Upload a `.txt` file to Cloud Storage. A Pub/Sub notification triggers a 2nd-gen Cloud Function, which finds the longest line(s) and writes a JSON result next to the output prefix.

```
week_3/data/foo.txt -> Cloud Function -> week_3/output/foo.json
```

## Files

| File | Purpose |
|---|---|
| `.cloud.env` | Project, bucket, prefixes, region, topic, and function name. |
| `bootstrap.sh` | Enables APIs, creates topic + notification, grants IAM, deploys function. |
| `main.py` | Cloud Function handler: downloads input, computes longest line(s), writes JSON and log. |
| `requirements.txt` | Python dependencies installed into the function image. |
| `.gcloudignore` | Files excluded from the deployed source bundle. |
| `data/*.txt` | Sample input files for demo/testing. |
| `.gitignore` | Excludes local `data/`, `output/`, `.venv/`, and `answer.csv`. |

## Run

Prerequisites: Google Cloud SDK installed and authenticated.

```bash
gcloud auth login
gcloud auth application-default login
```

From the repository root:

```bash
./bootstrap.sh
gcloud storage cp data/*.txt gs://ibd3t26-bucket/week_3/data/
```

Check results:

```bash
gcloud storage ls gs://ibd3t26-bucket/week_3/output/
gcloud storage cat gs://ibd3t26-bucket/week_3/output/cloud_pipeline.json
gcloud functions logs read gcs-artifact-processor --region=us-central1 --limit=20
```

Example output:

```json
{"filename": "week_3/data/cloud_pipeline.txt", "max_length": 72, "tie_lines": ["It finds the longest line and writes a JSON result to the output prefix."]}
```

`bootstrap.sh` is idempotent; rerunning it redeploys the function without creating duplicate topics or notifications.
