#  simple makefile

APP := "IBD week 6 assignment"

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

.PHONY: all sql-load sql-aggregations sql-scd-type1
all: sql-load sql-aggregations sql-scd-type1

sql-load:
	set -a; source .env; set +a
	envsubst < sql/00_load.sql > sql/00_load.rendered.sql
	spark-sql -f sql/00_load.rendered.sql

sql-aggregations:
	set -a; source .env; set +a
	envsubst < sql/01_aggregations.sql > sql/01_aggregations.rendered.sql
	spark-sql -f sql/01_aggregations.rendered.sql

sql-scd-type1:
	set -a; source .env; set +a
	envsubst < sql/02_scd_type1.sql > sql/02_scd_type1.rendered.sql
	spark-sql -f sql/02_scd_type1.rendered.sql

clean:
	rm -rf iceberg-warehouse spark-warehouse output derby.log metastore_db
