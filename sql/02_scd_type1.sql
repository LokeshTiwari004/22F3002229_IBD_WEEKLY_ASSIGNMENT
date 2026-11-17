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
