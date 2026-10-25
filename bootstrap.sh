#!/usr/bin/env bash
set -euo pipefail

source .cloud.env

gcloud auth application-default set-quota-project "$PROJECT_ID"
gcloud config set project "$PROJECT_ID"

gcloud services enable \
  cloudfunctions.googleapis.com \
  run.googleapis.com \
  eventarc.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  pubsub.googleapis.com \
  storage.googleapis.com \
  logging.googleapis.com

if ! gcloud pubsub topics describe "$EVENT_TOPIC" >/dev/null 2>&1; then
  gcloud pubsub topics create "$EVENT_TOPIC"
fi

PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
STORAGE_AGENT="service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com"
gcloud pubsub topics add-iam-policy-binding "$EVENT_TOPIC" \
  --member="serviceAccount:${STORAGE_AGENT}" \
  --role="roles/pubsub.publisher" >/dev/null

existing_notifications="$(gcloud storage buckets notifications list "gs://$BUCKET_NAME" --format='value("Notification Configuration".topic)')"
if ! printf '%s\n' "$existing_notifications" | grep -qE "(^|/)${EVENT_TOPIC}$"; then
  gcloud storage buckets notifications create "gs://$BUCKET_NAME" \
    --event-types="$EVENT_TYPE" \
    --object-prefix="$GCS_PREFIX" \
    --topic="$EVENT_TOPIC"
fi

gcloud functions deploy "$FUNCTION_NAME" \
  --gen2 \
  --runtime=python311 \
  --region="$LOCATION" \
  --source=. \
  --entry-point=process_artifact \
  --trigger-topic="$EVENT_TOPIC" \
  --set-env-vars="BUCKET_NAME=$BUCKET_NAME,GCS_PREFIX=$GCS_PREFIX,OUTPUT_PREFIX=$OUTPUT_PREFIX"


#   --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
#   --trigger-event-filters="bucket=$BUCKET_NAME" \
#   --trigger-event-filters-path-pattern="name=$GCS_PREFIX/*"