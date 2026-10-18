#!/bin/bash
set -euo pipefail

# Load cloud config variables:
#   PROJECT, BUCKET_NAME, GCS_PREFIX, DATA_DIR, ANSWER_CSV
source .cloud.env

# ── 1. Download data artifacts from GCS_PREFIX/data/ ─────────────────────────
mkdir -p "${DATA_DIR}"

echo "Downloading data artifacts from gs://${BUCKET_NAME}/${GCS_PREFIX}/${DATA_DIR}/ ..."
gcloud storage cp "gs://${BUCKET_NAME}/${GCS_PREFIX}/${DATA_DIR}/*" "${DATA_DIR}/"
echo "Download ${DATA_DIR}/ complete."

# ── 2. Download answer CSV from GCS_PREFIX/ ──────────────────────────────────
echo "Downloading ${ANSWER_CSV} from gs://${BUCKET_NAME}/${GCS_PREFIX}/${ANSWER_CSV} ..."
gcloud storage cp "gs://${BUCKET_NAME}/${GCS_PREFIX}/${ANSWER_CSV}" "${ANSWER_CSV}"
echo "Download ${ANSWER_CSV} complete."
