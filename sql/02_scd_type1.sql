-- Before
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type1_before'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- BEFORE Driver LOGS
SELECT 'Before SCD Type 1';
SELECT * FROM customer_master ORDER BY customer_id LIMIT 10;
SELECT COUNT(*) AS row_count FROM customer_master;


-- Apply SCD Type 1 (using MERGE requires ICEBERG/DELTA tables)
MERGE INTO customer_master m
USING customer_updates u
ON m.customer_id = u.customer_id
WHEN MATCHED THEN
    UPDATE SET
        m.customer_name = u.customer_name,
        m.city = u.city,
        m.dob = u.dob;


-- After
INSERT OVERWRITE DIRECTORY '${ROOT_DIR}/output/scd_type1_after'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- AFTER Driver LOGS
SELECT 'After SCD Type 1';
SELECT * FROM customer_master ORDER BY customer_id LIMIT 10;
SELECT COUNT(*) AS row_count FROM customer_master;
