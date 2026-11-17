-- Aggregation validation
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


-- SCD Type I validation
SELECT 'SCD Type I row count' AS check_name;
SELECT COUNT(*) AS row_count FROM customer_master;

SELECT 'SCD Type I updated customers' AS check_name;
SELECT m.customer_id, m.customer_name, m.city, m.dob
FROM customer_master m
JOIN customer_updates u
  ON m.customer_id = u.customer_id;


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
