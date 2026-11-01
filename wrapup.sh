source .env

gcloud config set project "$PROJECT_ID"
gcloud config set compute/region "$LOCATION"

mkdir -p output

gcloud storage cp --recursive \
  "gs://$BUCKET_NAME/$OUTPUT_GCS_PREFIX/*" \
  output/

gcloud dataproc clusters delete "$DATAPROC_CLUSTER_NAME" \
  --region="$LOCATION" \
  --quiet
