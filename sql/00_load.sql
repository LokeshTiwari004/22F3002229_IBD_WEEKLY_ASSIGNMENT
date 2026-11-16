DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
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

DROP TABLE IF EXISTS customer_master;
CREATE TABLE customer_master (
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

DROP TABLE IF EXISTS customer_updates;
CREATE TABLE customer_updates (
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