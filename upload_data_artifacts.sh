#!/bin/bash
set -euo pipefail

# Load cloud config variables:
#   PROJECT, BUCKET_NAME, BUCKET_LOCATION, BUCKET_STORAGE_CLASS, GCS_PREFIX,
#   DATA_DIR, OUTPUT_DIR, ANSWER_CSV
source .cloud.env

# ── 1. Create bucket if it does not already exist ────────────────────────────
if gcloud storage buckets describe "gs://${BUCKET_NAME}" > /dev/null 2>&1; then
    echo "Bucket gs://${BUCKET_NAME} already exists — skipping creation."
else
    echo "Creating bucket gs://${BUCKET_NAME} ..."
    gcloud storage buckets create "gs://${BUCKET_NAME}" \
        --project="${PROJECT}" \
        --location="${BUCKET_LOCATION}" \
        --default-storage-class="${BUCKET_STORAGE_CLASS}"
    echo "Bucket created."
fi

# ── 2. Upload new data artifacts from data/ ──────────────────────────────────
if [ ! -d "${DATA_DIR}" ]; then
    echo "ERROR: '${DATA_DIR}' directory not found. Run create_dataset.py first." >&2
    exit 1
fi

shopt -s nullglob
files=("${DATA_DIR}"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in '${DATA_DIR}'. Nothing to upload."
    exit 0
fi

echo "Uploading ${#files[@]} file(s) to gs://${BUCKET_NAME}/${GCS_PREFIX}/${DATA_DIR} ..."
gcloud storage cp --no-clobber "${DATA_DIR}"/* "gs://${BUCKET_NAME}/${GCS_PREFIX}/${DATA_DIR}/"
echo "Upload ${DATA_DIR}/ complete."

# ── 3. Upload output artifacts from output/ ───────────────────────────────────
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "ERROR: '${OUTPUT_DIR}' directory not found. Run analyze_data.py first." >&2
    exit 1
fi

shopt -s nullglob
files=("${OUTPUT_DIR}"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in '${OUTPUT_DIR}'. Nothing to upload."
    exit 0
fi

echo "Uploading ${#files[@]} file(s) to gs://${BUCKET_NAME}/${GCS_PREFIX}/${OUTPUT_DIR} ..."
gcloud storage cp --no-clobber "${OUTPUT_DIR}"/* "gs://${BUCKET_NAME}/${GCS_PREFIX}/${OUTPUT_DIR}/"
echo "Upload ${OUTPUT_DIR}/ complete."

# ── 4. Upload answer CSV (always overwrite to reflect latest run) ─────────────
if [ ! -f "${ANSWER_CSV}" ]; then
    echo "ERROR: '${ANSWER_CSV}' not found. Run analyze_data.py first." >&2
    exit 1
fi

echo "Uploading ${ANSWER_CSV} ..."
gcloud storage cp "${ANSWER_CSV}" "gs://${BUCKET_NAME}/${GCS_PREFIX}/${ANSWER_CSV}"
echo "Upload ${ANSWER_CSV} complete."