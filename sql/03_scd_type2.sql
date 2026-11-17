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
