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


gcloud services enable biglake.googleapis.com --project=${PROJECT_ID}


gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:service-857761332100@dataproc-accounts.iam.gserviceaccount.com" \
  --role="roles/biglake.admin"


gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:857761332100-compute@developer.gserviceaccount.com" \
  --role="roles/storage.admin"

# OPTIONAL:
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:857761332100-compute@developer.gserviceaccount.com" \
#   --role="roles/dataproc.worker"
