-- Clientes activos con ciudad y segmento.
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.city ciudad,
    c.segment segmento,
    c.created_at
FROM customers c
WHERE c.is_active = TRUE
ORDER BY c.created_at DESC;

--Pedidos de un cliente especifico con estado actual.
SELECT
    o.order_id,
    c.full_name,
    c.email,
    o.order_datetime,
    o.channel canal,
    o.current_status estado_actual,
    o.currency moneda,
    o.order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.email = 'fernandodiaz.s1oe@example.com'
ORDER BY o.order_datetime DESC;

--Detalle completo de un pedido con producto.
SELECT
    oi.order_id,
    p.sku,
    p.product_name,
    p.category categoria,
    p.brand marca,
    oi.quantity,
    oi.unit_price,
    oi.discount_rate,
    oi.line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.order_id = 7234
ORDER BY oi.order_item_id;

--Pagos de un pedido con metodo y estado.
SELECT
    p.payment_id,
    p.order_id,
    p.payment_datetime,
    p.method metodo_pago,
    p.payment_status estado_pago,
    p.currency moneda,
    p.amount
FROM payments p
WHERE p.order_id = 5135
ORDER BY p.payment_datetime;

--Historial de estados de un pedido para trazabilidad.
SELECT
    h.status_history_id,
    h.order_id,
    h.status estado,
    h.changed_at,
    h.changed_by actor,
    h.reason razon
FROM order_status_history h
WHERE h.order_id = 40
ORDER BY h.changed_at;

--Log de auditoria de cambios de campo por pedido.
SELECT
    oa.audit_id,
    oa.order_id,
    oa.field_name,
    oa.old_value,
    oa.new_value,
    oa.changed_at,
    oa.changed_by actor
FROM order_audit oa
WHERE oa.order_id = 12
ORDER BY oa.changed_at;

--Clientes dados de baja con fecha de eliminacion.
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.created_at,
    c.deleted_at,
    c.city ciudad,
    c.segment segmento
FROM customers c
WHERE c.deleted_at IS NOT NULL
ORDER BY c.deleted_at DESC;

--Productos activos ordenados por precio.
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category categoria,
    p.brand marca,
    p.unit_price,
    p.unit_cost,
    p.is_active
FROM products p
WHERE p.is_active = TRUE
ORDER BY p.unit_price DESC;

--Pedidos pagados por transferencia.
SELECT
    o.order_id,
    c.full_name,
    o.order_datetime,
    p.payment_datetime,
    p.method metodo,
    p.payment_status estado_pago,
    p.amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN payments p ON p.order_id = o.order_id
WHERE p.method = 'transfer'
ORDER BY p.payment_datetime DESC;

--Ultimos cambios de estado realizados por system.
SELECT
    h.status_history_id,
    h.order_id,
    h.status nuevo_estado,
    h.changed_at,
    h.changed_by actor,
    h.reason razon
FROM order_status_history h
WHERE h.changed_by = 'system'
ORDER BY h.changed_at DESC;

--Ordenes huerfanas sin cliente valido.
SELECT
    o.order_id,
    o.customer_id,
    o.order_datetime,
    o.order_total
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY o.order_id;

--Items huerfanos sin pedido valido.
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.line_total
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
ORDER BY oi.order_id;

--Pagos huerfanos sin pedido valido.
SELECT
    p.payment_id,
    p.order_id,
    p.amount,
    p.payment_datetime
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL
ORDER BY p.order_id;

--Clientes con deleted_at anterior a created_at.
SELECT
    customer_id,
    full_name,
    created_at,
    deleted_at
FROM customers
WHERE deleted_at IS NOT NULL
  AND deleted_at < created_at
ORDER BY customer_id;

--Pagos anteriores a la creacion del pedido.
SELECT
    p.payment_id,
    p.order_id,
    o.order_datetime,
    p.payment_datetime,
    p.amount
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.payment_datetime < o.order_datetime
ORDER BY p.payment_id;

--Pedidos con order_total igual a cero. 5934 'inconsistencia'
SELECT
    o.order_id,
    c.full_name,
    o.order_datetime,
    o.order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_total = 0
ORDER BY o.order_id;

--Pedidos sin ningun item asociado. 5934 'inconsistencia'
SELECT
    o.order_id,
    c.full_name,
    o.order_datetime,
    o.order_total,
    o.current_status estado
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_id NOT IN (SELECT DISTINCT oi.order_id FROM order_items oi)
ORDER BY o.order_id;

--Clientes con email invalido sin caracter @.
SELECT
    customer_id,
    full_name,
    email,
    created_at
FROM customers
WHERE email NOT LIKE '%@%'
ORDER BY customer_id;

--Items de orden con producto inexistente.
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.line_total
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
ORDER BY oi.order_item_id;

