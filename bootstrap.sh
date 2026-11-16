#!/bin/bash
source .env
set -euo pipefail

gcloud config configurations activate ${ACCOUNT}
# gcloud auth login
# gcloud auth application-default login
gcloud auth application-default set-quota-project $PROJECT_ID
gcloud config set billing/quota_project $PROJECT_ID
gcloud config set project $PROJECT_ID
gcloud config set compute/region $LOCATION

if ! gcloud storage buckets list | grep -q ${BUCKET_NAME}; then
    gcloud storage buckets create gs://${BUCKET_NAME} --location=${LOCATION} --default-storage-class=${STORAGE_CLASS}
fi

gcloud storage cp --no-clobber --recursive ./data gs://${BUCKET_NAME}/${GCS_PREFIX}/
