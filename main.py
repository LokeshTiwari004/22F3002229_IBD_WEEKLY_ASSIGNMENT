import base64
import json
import logging
import os

import functions_framework
from google.cloud import logging as cloud_logging
from google.cloud import storage

BUCKET = os.environ["BUCKET_NAME"]
OUT_PREFIX = os.environ["OUTPUT_PREFIX"]


@functions_framework.cloud_event
def process_artifact(cloud_event):
    message = cloud_event.data.get("message", {})
    raw_data = message.get("data")
    if not raw_data:
        logging.warning("Pub/Sub message has no data")
        return

    data = json.loads(base64.b64decode(raw_data).decode("utf-8"))
    name = data.get("name", "")
    if not name.endswith(".txt"):
        logging.warning("Ignoring non-txt file: %s", name)
        return

    client = storage.Client()
    bucket = client.bucket(BUCKET)
    content = bucket.blob(name).download_as_text().splitlines()
    max_len = max((len(line) for line in content), default=0)
    longest = [line for line in content if len(line) == max_len]
    result = {"filename": name, "max_length": max_len, "tie_lines": longest}

    out_name = f"{name.rsplit('/', 1)[-1].removesuffix('.txt')}.json"
    out_path = f"{OUT_PREFIX}/{out_name}"
    bucket.blob(out_path).upload_from_string(json.dumps(result))

    logger = cloud_logging.Client().logger("cloud_function_log")
    logger.log_struct(result)
