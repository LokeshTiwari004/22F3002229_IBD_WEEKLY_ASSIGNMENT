-- create temporary views
CREATE TEMPORARY VIEW transactions_tv (
  transaction_id STRING,
  customer_id STRING,
  transaction_date DATE,
  transaction_amount INT,
  payment_mode STRING,
  city STRING
) USING csv
OPTIONS (
  path '${INPUT_PREFIX}/data/transactions.csv',
  header 'true'
);

CREATE TEMPORARY VIEW customer_master_tv (
  customer_id STRING,
  customer_name STRING,
  city STRING,
  dob DATE,
  effective_date DATE,
  expiry_date DATE,
  current_flag INT
) USING csv
OPTIONS (
  path '${INPUT_PREFIX}/data/customer_master.csv',
  header 'true'
);

CREATE TEMPORARY VIEW customer_updates_tv (
  customer_id STRING,
  customer_name STRING,
  city STRING,
  dob DATE,
  change_date DATE
) USING csv
OPTIONS (
  path '${INPUT_PREFIX}/data/customer_updates.csv',
  header 'true'
);


--- 2. Materialize the Data
CREATE TABLE IF NOT EXISTS transactions
USING parquet
AS
SELECT * FROM transactions_tv;

CREATE TABLE IF NOT EXISTS customer_master
USING parquet
AS
SELECT * FROM customer_master_tv;

CREATE TABLE IF NOT EXISTS customer_updates
USING parquet
AS
SELECT * FROM customer_updates_tv;
