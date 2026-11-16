#  simple makefile

APP := "IBD week 6 assignment"

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

.PHONY: all sql-load
all: sql-load

sql-load:
	set -a; source .env; set +a
	envsubst < sql/00_load.sql > sql/00_load.rendered.sql
	spark-sql -f sql/00_load.rendered.sql
