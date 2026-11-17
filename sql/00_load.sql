-- create temporary views
CREATE OR REPLACE TEMPORARY VIEW transactions_tv (
  transaction_id STRING,
  customer_id STRING,
  transaction_date DATE,
  transaction_amount INT,
  payment_mode STRING,
  city STRING
) USING csv
OPTIONS (
  path '${ROOT_DIR}/data/transactions.csv',
  header 'true'
);

CREATE OR REPLACE TEMPORARY VIEW customer_master_tv (
  customer_id STRING,
  customer_name STRING,
  city STRING,
  dob DATE,
  effective_date DATE,
  expiry_date DATE,
  current_flag INT
) USING csv
OPTIONS (
  path '${ROOT_DIR}/data/customer_master.csv',
  header 'true'
);

CREATE OR REPLACE TEMPORARY VIEW customer_updates_tv (
  customer_id STRING,
  customer_name STRING,
  city STRING,
  dob DATE,
  change_date DATE
) USING csv
OPTIONS (
  path '${ROOT_DIR}/data/customer_updates.csv',
  header 'true'
);


-- 2. Materialize the Data
CREATE TABLE IF NOT EXISTS transactions
USING iceberg
AS
SELECT * FROM transactions_tv;

DROP TABLE IF EXISTS customer_master;
CREATE TABLE customer_master
USING iceberg
AS
SELECT * FROM customer_master_tv;

CREATE TABLE IF NOT EXISTS customer_updates
USING iceberg
AS
SELECT * FROM customer_updates_tv;
