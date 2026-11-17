#  simple makefile

APP := "IBD week 6 assignment"

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
-include .env
export

.PHONY:
all: local-load local-aggregations local-scd-type1 local-scd-type2

local-load:
	spark-sql -f sql/00_load.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-aggregations:
	spark-sql -f sql/01_aggregations.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-scd-type1: local-load
	spark-sql -f sql/02_scd_type1.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-scd-type2: local-load
	spark-sql -f sql/03_scd_type2.sql --hivevar ROOT_DIR=${ROOT_DIR}


gcp-cluster-create:
	gcloud dataproc clusters create cluster-59ac --enable-component-gateway --region us-east4 --subnet default --no-address --master-machine-type n4a-standard-1 --master-boot-disk-type hyperdisk-balanced --master-boot-disk-size 500 --num-workers 1 --worker-machine-type n4a-standard-1 --worker-boot-disk-type hyperdisk-balanced --worker-boot-disk-size 500 --secondary-worker-boot-disk-type hyperdisk-balanced --secondary-worker-boot-disk-size 500 --image-version 2.3-debian12 --properties spark:spark.dataproc.engine=lightningEngine,spark:spark.dataproc.lightningEngine.runtime=default,dataproc:dataproc.logging.stackdriver.job.driver.enable=true,spark:spark.dataproc.lakehouse.project=ibd-3t26-22f3002229,dataproc:dataproc.lakehouse.defaultCatalog=standard-lh-catalog-us-east4 --optional-components ICEBERG --scopes 'https://www.googleapis.com/auth/cloud-platform' --secondary-worker-type non-preemptible --project ibd-3t26-22f3002229

clean:
	rm -rf iceberg-warehouse spark-warehouse output derby.log metastore_db
