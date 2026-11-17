-- Before
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type2_before'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id, effective_date;

-- Before Driver LOGS
SELECT 'Before SCD Type 2';
SELECT * FROM customer_master ORDER BY customer_id, effective_date LIMIT 10;


-- Merge SCD Type 2
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


-- After
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type2_after'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id, effective_date;

-- After Driver LOGS
SELECT 'After SCD Type 2';
SELECT * FROM customer_master ORDER BY customer_id, effective_date LIMIT 15;
