SELECT * FROM staging_customers LIMIT 100000

SELECT *
FROM staging_payments
WHERE amount::NUMERIC(12,2) <= 0;

SELECT payment_id, order_id, amount, payment_status
FROM staging_payments
WHERE amount::NUMERIC(12,2) <= 0
ORDER BY amount::NUMERIC(12,2);

SELECT * FROM payments

