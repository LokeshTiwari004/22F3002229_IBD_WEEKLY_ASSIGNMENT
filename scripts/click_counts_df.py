import os

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, hour, when

spark = SparkSession.builder.appName("ClickCountsDF").getOrCreate()

BUCKET_NAME = os.getenv("BUCKET_NAME", "ibd3t26-bucket")
INPUT_GCS_PREFIX = os.getenv("INPUT_GCS_PREFIX", "week_4/input")
OUTPUT_GCS_PREFIX = os.getenv("OUTPUT_GCS_PREFIX", "week_4/output")
INPUT_FILE = os.getenv("INPUT_FILE", "click_file.txt")

input_path = f"gs://{BUCKET_NAME}/{INPUT_GCS_PREFIX}/{INPUT_FILE}"
base_name = os.path.splitext(INPUT_FILE)[0]
output_path = f"gs://{BUCKET_NAME}/{OUTPUT_GCS_PREFIX}/{base_name}.df"

df = spark.read.csv(input_path, header=True, inferSchema=True)
df = df.withColumn("timestamp", col("timestamp").cast("timestamp"))
df = df.withColumn("hour", hour(col("timestamp")))

df = df.withColumn(
    "time_bin",
    when((col("hour") >= 0) & (col("hour") < 6), "0-6 hours")
    .when((col("hour") >= 6) & (col("hour") < 12), "6-12 hours")
    .when((col("hour") >= 12) & (col("hour") < 18), "12-18 hours")
    .otherwise("18-24 hours"),
)

result = df.groupBy("time_bin").count()

result.write.csv(output_path, header=True, mode="overwrite")

spark.stop()
