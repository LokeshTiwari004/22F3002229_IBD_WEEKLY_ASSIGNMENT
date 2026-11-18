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
-- Top 5 customers by total transaction amount
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/top5_customers'
USING csv OPTIONS (header 'true')
SELECT
    customer_id,
    SUM(transaction_amount) AS total_transaction_amount
FROM transactions
GROUP BY customer_id
ORDER BY total_transaction_amount DESC
LIMIT 5;


-- Customers per city
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/customers_per_city'
USING csv OPTIONS (header 'true')
SELECT
    city,
    COUNT(DISTINCT customer_id) AS customer_count
FROM transactions
GROUP BY city
ORDER BY customer_count DESC;

-- Average transactions amount over all
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/average_transaction_amount'
USING csv OPTIONS (header 'true')
SELECT
    AVG(transaction_amount) AS average_transaction_amount
FROM transactions;


-- Log result and validation

SELECT 'Aggregations completed';

SELECT 'Top 5 customers' AS check_name;
SELECT * FROM (
  SELECT customer_id, SUM(transaction_amount) AS total_amount
  FROM transactions
  GROUP BY customer_id
  ORDER BY total_amount DESC
  LIMIT 5
);

SELECT 'Customers per city' AS check_name;
SELECT city, COUNT(DISTINCT customer_id) AS customer_count
FROM transactions
GROUP BY city
ORDER BY customer_count DESC;

SELECT 'Average transaction value' AS check_name;
SELECT AVG(transaction_amount) AS avg_transaction_value
FROM transactions;
-- save customer_master BEFORE SCD Type I
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type1_before'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- customer_master BEFORE PREVIEW
SELECT 'Before SCD Type 1';
SELECT * FROM customer_master ORDER BY customer_id LIMIT 10;


-- Apply SCD Type I
MERGE INTO customer_master m
USING customer_updates u
ON m.customer_id = u.customer_id
WHEN MATCHED THEN
    UPDATE SET
        m.customer_name = u.customer_name,
        m.city = u.city,
        m.dob = u.dob;


-- save customer_master AFTER SCD Type I
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type1_after'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- customer_master AFTER PREVIEW
SELECT 'After SCD Type 1';
SELECT * FROM customer_master ORDER BY customer_id LIMIT 10;



-- SCD Type I validation
SELECT 'SCD Type I row count' AS check_name;
SELECT COUNT(*) AS row_count FROM customer_master;

SELECT 'SCD Type I updated customers' AS check_name;
SELECT
    m.customer_id,
    m.customer_name AS updated_name,
    m.city AS updated_city,
    m.dob AS updated_dob
FROM customer_master m
JOIN customer_updates u
  ON m.customer_id = u.customer_id;
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
-- save customer_master BEFORE SCD Type II
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type2_before'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id, effective_date;

-- customer_master BEFORE PREVIEW
SELECT 'Before SCD Type 2';
SELECT * FROM customer_master ORDER BY customer_id, effective_date LIMIT 10;
SELECT COUNT(*) AS row_count FROM customer_master;


-- Apply SCD Type II
-- Expire old current records
MERGE INTO customer_master AS m
USING customer_updates AS u
ON m.customer_id = u.customer_id AND m.current_flag = 1
WHEN MATCHED THEN
    UPDATE SET
    m.current_flag = 0,
    m.expiry_date = u.change_date;

-- Insert new versions
INSERT INTO customer_master
SELECT
    u.customer_id,
    u.customer_name,
    u.city,
    u.dob,
    u.change_date AS effective_date,
    NULL AS expiry_date,
    1 AS current_flag
FROM customer_updates u;


-- save customer_master AFTER SCD Type II
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type2_after'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id, effective_date;

-- customer_master AFTER PREVIEW
SELECT 'After SCD Type 2';
SELECT * FROM customer_master ORDER BY customer_id, effective_date LIMIT 15;



-- SCD Type II validation
SELECT 'SCD Type II total rows' AS check_name;
SELECT COUNT(*) AS total_rows FROM customer_master;

SELECT 'SCD Type II current rows' AS check_name;
SELECT COUNT(*) AS current_rows
FROM customer_master
WHERE current_flag = 1;

SELECT 'SCD Type II version counts' AS check_name;
SELECT customer_id, COUNT(*) AS version_count
FROM customer_master
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT 'SCD Type II expired records' AS check_name;
SELECT customer_id, effective_date, expiry_date, current_flag
FROM customer_master
WHERE current_flag = 0
ORDER BY customer_id;
