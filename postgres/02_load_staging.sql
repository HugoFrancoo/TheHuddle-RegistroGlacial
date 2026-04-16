TRUNCATE TABLE
    staging_order_audit,
    staging_order_status_history,
    staging_payments,
    staging_order_items,
    staging_orders,
    staging_products,
    staging_customers
CASCADE;
--header true, la primera fila no la carga
\copy staging_customers (customer_id, full_name, email, phone, city, segment, created_at, is_active, deleted_at) FROM '../data/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_products (product_id, sku, product_name, category, brand, unit_price, unit_cost, created_at, is_active, deleted_at) FROM '../data/products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_orders (order_id, customer_id, order_datetime, channel, currency, current_status, is_active, deleted_at, order_total) FROM '../data/orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_rate, line_total) FROM '../data/order_items.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_payments (payment_id, order_id, payment_datetime, method, payment_status, amount, currency) FROM '../data/payments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_order_status_history (status_history_id, order_id, status, changed_at, changed_by, reason) FROM '../data/order_status_history.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy staging_order_audit (audit_id, order_id, field_name, old_value, new_value, changed_at, changed_by) FROM '../data/order_audit.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
