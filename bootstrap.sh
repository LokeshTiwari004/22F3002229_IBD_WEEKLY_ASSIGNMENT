source .env

gcloud config configurations activate default
gcloud config set project "$PROJECT_ID"
gcloud auth application-default set-quota-project "$PROJECT_ID"
gcloud config set compute/region "$LOCATION"

gcloud services enable cloudresourcemanager.googleapis.com dataproc.googleapis.com compute.googleapis.com --project "$PROJECT_ID"

gcloud storage cp --recursive scripts/*.py "gs://$BUCKET_NAME/$SCRIPTS_GCS_PREFIX/"

if gcloud dataproc clusters describe "$DATAPROC_CLUSTER_NAME" --region "$LOCATION" >/dev/null 2>&1; then
  echo "Cluster $DATAPROC_CLUSTER_NAME already exists; skipping creation."
else
  gcloud dataproc clusters create "$DATAPROC_CLUSTER_NAME" \
    --enable-component-gateway \
    --region "$LOCATION" \
    --zone us-central1-b \
    --subnet default \
    --no-address \
    --master-machine-type n4-standard-2 \
    --master-boot-disk-type hyperdisk-balanced \
    --master-boot-disk-size 100 \
    --num-workers 2 \
    --worker-machine-type n4-standard-2 \
    --worker-boot-disk-type hyperdisk-balanced \
    --worker-boot-disk-size 100 \
    --secondary-worker-boot-disk-type hyperdisk-balanced \
    --secondary-worker-boot-disk-size 100 \
    --image-version 3.0-ubuntu24 \
    --properties spark:spark.dataproc.engine=lightningEngine,spark:spark.dataproc.lightningEngine.runtime=default,dataproc:dataproc.logging.stackdriver.job.driver.enable=true,spark-env:BUCKET_NAME=$BUCKET_NAME,spark-env:INPUT_GCS_PREFIX=$INPUT_GCS_PREFIX,spark-env:OUTPUT_GCS_PREFIX=$OUTPUT_GCS_PREFIX \
    --optional-components ICEBERG,DELTA,JUPYTER \
    --scopes 'https://www.googleapis.com/auth/cloud-platform' \
    --secondary-worker-type non-preemptible \
    --project "$PROJECT_ID"
fi
