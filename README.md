# IBD Weekly Assignment — 22F3002229

## Repository Structure

| File / Directory | Role |
|---|---|
| `.cloud.env` | Environment config: `PROJECT`, `BUCKET_NAME`, `BUCKET_LOCATION`, `BUCKET_STORAGE_CLASS`, `GCS_PREFIX`, `DATA_DIR`, `OUTPUT_DIR`, `ANSWER_CSV` |
| `requirements.txt` | Python package dependencies for the environment |
| `create_dataset.py` | Generates synthetic `.txt` files with random alphanumeric content and writes them to `data/` |
| `analyze_data.py` | Finds the longest sentence(s) per file, writes per-file results to `output/`, and appends rows to `answer.csv` |
| `upload_data_artifacts.sh` | Creates the GCS bucket (idempotent), uploads `data/`, `output/`, and `answer.csv` to GCS |
| `fetch_data_artifacts.sh` | Downloads `data/` files and `answer.csv` from GCS to the local workspace |
| `data/` | Auto-generated input `.txt` files (created by `create_dataset.py`) |
| `output/` | Per-file analysis results in `<name>.longest.txt` format (created by `analyze_data.py`) |
| `answer.csv` | Aggregated results table: `filename, longest_length` (created/appended by `analyze_data.py`) |

## Remote Execution Pipeline

```bash
# Step 1 — Create virtual environment and install dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Step 2 — Fetch existing data artifacts and answer.csv from GCS
bash fetch_data_artifacts.sh

# Step 3 — (Optional) Generate additional data files
#           Skip if fetched data is sufficient for the run
python3 create_dataset.py

# Step 4 — Analyse all files in data/ → output/ and answer.csv
python3 analyze_data.py

# Step 5 — Upload data/, output/, and answer.csv back to GCS
bash upload_data_artifacts.sh
```

## Configuration

All cloud parameters are sourced from `.cloud.env` at runtime. Edit that file before running any shell script.

```
GCS path layout:  gs://<BUCKET_NAME>/<GCS_PREFIX>/data/
                  gs://<BUCKET_NAME>/<GCS_PREFIX>/output/
                  gs://<BUCKET_NAME>/<GCS_PREFIX>/answer.csv
```

## Notes

- `upload_data_artifacts.sh` uses `--no-clobber` for `data/` and `output/` to avoid overwriting existing artifacts; `answer.csv` is always overwritten to reflect the latest run.
- `analyze_data.py` handles ties — multiple lines/sentences of equal maximum length are all recorded.
- Each generated `.txt` file ends with an integer on the last line indicating the maximum sentence length used during generation.