#  simple makefile

APP := "IBD week 6 assignment"

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
-include .env
export

.PHONY:
all: local-load local-aggregations local-scd-type1 local-scd-type2
all-gcp: gcp-cluster-create gcp-job-submit gcp-fetch-results gcp-cluster-delete

check:
	echo $${CLUSTER_NAME}

local-load:
	spark-sql -f sql/00_load.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-aggregations:
	spark-sql -f sql/01_aggregations.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-scd-type1: local-load
	spark-sql -f sql/02_scd_type1.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-scd-type2: local-load
	spark-sql -f sql/03_scd_type2.sql --hivevar ROOT_DIR=${ROOT_DIR}


gcp-cluster-create:
	gcloud dataproc clusters create ${CLUSTER_NAME} --region=${LOCATION} --flags-file=cluster-config.yaml

gcp-job-submit:
	cat sql/00_load.sql sql/01_aggregations.sql sql/02_scd_type1.sql sql/00_load.sql sql/03_scd_type2.sql > sql/assignment_all.sql
	gcloud storage cp sql/assignment_all.sql gs://${BUCKET_NAME}/${GCS_PREFIX}/sql/
	gcloud dataproc jobs submit spark-sql \
	  --cluster=${CLUSTER_NAME} \
	  --region=${LOCATION} \
	  --file=gs://${BUCKET_NAME}/${GCS_PREFIX}/sql/assignment_all.sql \
	  --params=ROOT_DIR=${GCS_ROOT_DIR}

gcp-fetch-results: clean
	gcloud storage cp --recursive gs://${BUCKET_NAME}/${GCS_PREFIX}/output/ .

gcp-cluster-delete:
	gcloud dataproc clusters delete ${CLUSTER_NAME} --region=${LOCATION}

clean:
	rm -rf iceberg-warehouse spark-warehouse output derby.log metastore_db
