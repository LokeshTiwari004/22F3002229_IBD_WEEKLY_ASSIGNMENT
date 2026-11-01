source .env

gcloud config set project "$PROJECT_ID"
gcloud config set compute/region "$LOCATION"

INPUT_FILE="click_file.txt"

gcloud storage cp \
  "input/$INPUT_FILE" \
  "gs://$BUCKET_NAME/$INPUT_GCS_PREFIX/$INPUT_FILE"

gcloud dataproc jobs submit pyspark \
  "gs://$BUCKET_NAME/$SCRIPTS_GCS_PREFIX/click_counts_rdd.py" \
  --cluster="$DATAPROC_CLUSTER_NAME" \
  --region="$LOCATION" \
  --properties "spark.executorEnv.INPUT_FILE=$INPUT_FILE,spark.driverEnv.INPUT_FILE=$INPUT_FILE"

gcloud dataproc jobs submit pyspark \
  "gs://$BUCKET_NAME/$SCRIPTS_GCS_PREFIX/click_counts_df.py" \
  --cluster="$DATAPROC_CLUSTER_NAME" \
  --region="$LOCATION" \
  --properties "spark.executorEnv.INPUT_FILE=$INPUT_FILE,spark.driverEnv.INPUT_FILE=$INPUT_FILE"
