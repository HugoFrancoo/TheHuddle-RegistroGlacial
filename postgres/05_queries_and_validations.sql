-- Consulta 1: pedidos con datos del cliente
SELECT
    o.order_id,
    o.order_datetime,
    o.channel,
    o.currency,
    o.order_total,
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.city,
    c.segment
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_datetime DESC;

-- Consulta 2: detalle de items por SKU
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.quantity,
    oi.unit_price AS item_unit_price,
    oi.discount_rate,
    oi.line_total,
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.brand,
    p.unit_price AS product_unit_price,
    p.is_active
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE p.sku = 'SKU-658EDSCIEQ'
ORDER BY oi.order_item_id;

-- Consulta 3: pagos de un pedido
SELECT
    p.payment_id,
    p.order_id,
    p.payment_datetime,
    p.method,
    p.payment_status,
    p.amount,
    p.currency
FROM payments p
WHERE p.order_id = 84574
ORDER BY p.payment_datetime;

-- Consulta 4: historial de estados de un pedido
SELECT
    h.status_history_id,
    h.order_id,
    h.status,
    h.changed_at,
    h.changed_by,
    h.reason
FROM order_status_history h
WHERE h.order_id = 84574
ORDER BY h.changed_at ASC;

-- Consulta 5: auditoria de un pedido
SELECT
    a.audit_id,
    a.order_id,
    a.field_name,
    a.old_value,
    a.new_value,
    a.changed_at,
    a.changed_by
FROM order_audit a
WHERE a.order_id = 845
ORDER BY a.changed_at;

-- ===========================================
-- Validaciones de integridad y negocio
-- ===========================================

-- Validacion 1: pedidos sin cliente
SELECT
    o.*
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Validacion 2: items sin pedido
SELECT
    oi.*
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Validacion 3: items sin producto
SELECT
    oi.*
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Validacion 4: pagos sin pedido
SELECT
    p.*
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Validacion 5: historial sin pedido
SELECT
    h.*
FROM order_status_history h
LEFT JOIN orders o
    ON h.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Validacion 6: auditoria sin pedido
SELECT
    a.*
FROM order_audit a
LEFT JOIN orders o
    ON a.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Validacion 7: pedidos sin items
SELECT
    o.order_id
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Validacion 8: pedidos sin pagos
SELECT
    o.order_id
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- Validacion 9: pedidos sin historial
SELECT
    o.order_id
FROM orders o
LEFT JOIN order_status_history h
    ON o.order_id = h.order_id
WHERE h.order_id IS NULL;

-- Validacion 10: moneda del pago distinta a la del pedido
SELECT
    p.payment_id,
    p.order_id,
    p.amount,
    p.currency AS payment_currency,
    o.currency AS order_currency
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
WHERE p.currency <> o.currency;

-- Validacion 11: estado actual del pedido no aparece en historial
SELECT
    o.order_id,
    o.current_status
FROM orders o
LEFT JOIN order_status_history h
    ON o.order_id = h.order_id
   AND o.current_status = h.status
WHERE h.status_history_id IS NULL;

-- Validacion 12: pedidos entregados sin pagos aprobados
SELECT
    o.order_id,
    o.current_status
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
   AND p.payment_status = 'approved'
WHERE o.current_status = 'delivered'
  AND p.payment_id IS NULL;

-- Validacion 13: pagos aprobados con monto 0
SELECT
    p.payment_id,
    p.order_id,
    p.amount,
    p.payment_status
FROM payments p
WHERE p.payment_status = 'approved'
  AND p.amount = 0;

-- Validacion 14: pedidos cancelados con pagos aprobados
SELECT
    o.order_id,
    o.current_status,
    p.payment_id,
    p.payment_status,
    p.amount
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.current_status = 'cancelled'
  AND p.payment_status = 'approved';

-- Validacion 15: customers con soft delete inconsistente
SELECT
    c.*
FROM customers c
WHERE (c.is_active = TRUE  AND c.deleted_at IS NOT NULL)
   OR (c.is_active = FALSE AND c.deleted_at IS NULL);

-- Validacion 16: products con soft delete inconsistente
SELECT
    p.*
FROM products p
WHERE (p.is_active = TRUE  AND p.deleted_at IS NOT NULL)
   OR (p.is_active = FALSE AND p.deleted_at IS NULL);

-- Validacion 17: orders con soft delete inconsistente
SELECT
    o.*
FROM orders o
WHERE (o.is_active = TRUE  AND o.deleted_at IS NOT NULL)
   OR (o.is_active = FALSE AND o.deleted_at IS NULL);

-- Validacion 18: auditorias sin cambio real
SELECT
    a.*
FROM order_audit a
WHERE a.old_value = a.new_value;

-- Validacion 19: auditorias vacias
SELECT
    a.*
FROM order_audit a
WHERE a.old_value IS NULL
  AND a.new_value IS NULL;