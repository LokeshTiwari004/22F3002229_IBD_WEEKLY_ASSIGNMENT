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


-- Log result

SELECT 'Aggregations completed';

SELECT customer_id, SUM(transaction_amount) AS total_amount
FROM transactions
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 5;

SELECT city, COUNT(DISTINCT customer_id) AS customer_count
FROM transactions
GROUP BY city
ORDER BY customer_count DESC;

SELECT AVG(transaction_amount) AS average_transaction_amount
FROM transactions;
