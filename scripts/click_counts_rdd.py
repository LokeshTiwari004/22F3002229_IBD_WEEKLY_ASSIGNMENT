import os

from datetime import datetime

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("ClickCountsRDD").getOrCreate()
sc = spark.sparkContext

BUCKET_NAME = os.getenv("BUCKET_NAME", "ibd3t26-bucket")
INPUT_GCS_PREFIX = os.getenv("INPUT_GCS_PREFIX", "week_4/input")
OUTPUT_GCS_PREFIX = os.getenv("OUTPUT_GCS_PREFIX", "week_4/output")
INPUT_FILE = os.getenv("INPUT_FILE", "click_file.txt")

input_path = f"gs://{BUCKET_NAME}/{INPUT_GCS_PREFIX}/{INPUT_FILE}"
base_name = os.path.splitext(INPUT_FILE)[0]
output_path = f"gs://{BUCKET_NAME}/{OUTPUT_GCS_PREFIX}/{base_name}.rdd"


def hour_to_bin(hour):
    if 0 <= hour < 6:
        return "0-6 hours"
    if 6 <= hour < 12:
        return "6-12 hours"
    if 12 <= hour < 18:
        return "12-18 hours"
    return "18-24 hours"


lines = sc.textFile(input_path)
data_lines = lines.filter(lambda line: not line.lower().startswith("user_id"))

timestamps = data_lines.map(lambda line: line.split(",")[1].strip())
hours = timestamps.map(
    lambda ts: datetime.strptime(ts, "%Y-%m-%d %H:%M:%S").hour
)
bins = hours.map(hour_to_bin)

counts = bins.map(lambda time_bin: (time_bin, 1)).reduceByKey(
    lambda a, b: a + b
)

counts.saveAsTextFile(output_path)

spark.stop()
