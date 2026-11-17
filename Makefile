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

local-scd-type1: local-sql-load
	spark-sql -f sql/02_scd_type1.sql --hivevar ROOT_DIR=${ROOT_DIR}

local-scd-type2: local-sql-load
	spark-sql -f sql/03_scd_type2.sql --hivevar ROOT_DIR=${ROOT_DIR}

clean:
	rm -rf iceberg-warehouse spark-warehouse output derby.log metastore_db
