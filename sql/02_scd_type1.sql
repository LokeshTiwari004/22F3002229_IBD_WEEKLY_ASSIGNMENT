-- Before
INSERT OVERWRITE DIRECTORY '${ROOT_DIR_PATH}/output/scd_type1_before'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- BEFORE Driver Legs
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

-- -- Apply SCD Type 1 (using INSERT OVERWRITE)
-- CREATE OR REPLACE TEMP VIEW customer_master_scd1 AS
-- SELECT
--   m.customer_id,
--   COALESCE(u.customer_name, m.customer_name) AS customer_name,
--   COALESCE(u.city, m.city) AS city,
--   COALESCE(u.dob, m.dob) AS dob,
--   m.effective_date,
--   m.expiry_date,
--   m.current_flag
-- FROM customer_master m
-- LEFT JOIN customer_updates u
--   ON m.customer_id = u.customer_id;
--
-- INSERT OVERWRITE TABLE customer_master
-- SELECT * FROM customer_master_scd1;


-- After
INSERT OVERWRITE DIRECTORY '${ROOT_DIR_PATH}/output/scd_type1_after'
USING csv OPTIONS (header 'true')
SELECT * FROM customer_master ORDER BY customer_id;

-- AFTER Driver Legs`
SELECT 'After SCD Type 1';
SELECT * FROM customer_master ORDER BY customer_id LIMIT 10;
SELECT COUNT(*) AS row_count FROM customer_master;
