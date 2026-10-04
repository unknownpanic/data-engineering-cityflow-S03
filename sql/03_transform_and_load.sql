BEGIN;

INSERT INTO audit.runs (batch_id, status) VALUES ('MANUAL_RUN', 'running');

INSERT INTO core.customers (customer_id, full_name, city, registered_at)
SELECT customer_id, full_name, city, CAST(registered_at AS TIMESTAMPTZ)
FROM stg.customers
WHERE customer_id IS NOT NULL
  AND registered_at ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])'
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO core.merchants (merchant_id, merchant_name, city, opened_at)
SELECT merchant_id, merchant_name, city, CAST(opened_at AS TIMESTAMPTZ)
FROM stg.merchants
WHERE merchant_id IS NOT NULL
ON CONFLICT (merchant_id) DO NOTHING;

INSERT INTO core.products (product_id, merchant_id, product_name, unit_price_uah, is_active)
SELECT product_id, merchant_id, product_name, CAST(unit_price_uah AS NUMERIC), CAST(is_active AS BOOLEAN)
FROM stg.products
WHERE product_id IS NOT NULL
  AND merchant_id IN (SELECT merchant_id FROM core.merchants)
  AND NOT (CAST(is_active AS BOOLEAN) = TRUE AND CAST(unit_price_uah AS NUMERIC) <= 0)
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO core.orders (order_id, customer_id, merchant_id, created_at, order_status, currency, subtotal_amount, delivery_fee, discount_amount, total_amount)
SELECT order_id, customer_id, merchant_id, CAST(created_at AS TIMESTAMPTZ), order_status, currency, CAST(subtotal_amount AS NUMERIC), CAST(delivery_fee AS NUMERIC), CAST(discount_amount AS NUMERIC), CAST(total_amount AS NUMERIC)
FROM stg.orders
WHERE order_id IS NOT NULL
  AND customer_id IN (SELECT customer_id FROM core.customers)
  AND merchant_id IN (SELECT merchant_id FROM core.merchants)
  AND created_at ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])'
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO core.order_items (order_item_id, order_id, product_id, quantity, unit_price, line_discount, line_total, currency)
SELECT order_item_id, order_id, product_id, CAST(quantity AS INT), CAST(unit_price AS NUMERIC), CAST(line_discount AS NUMERIC), CAST(line_total AS NUMERIC), currency
FROM stg.order_items
WHERE order_item_id IS NOT NULL
  AND CAST(quantity AS INT) > 0
  AND order_id IN (SELECT order_id FROM core.orders)
  AND product_id IN (SELECT product_id FROM core.products)
ON CONFLICT (order_item_id) DO NOTHING;

UPDATE audit.runs SET finished_at = NOW(), status = 'success' WHERE status = 'running';

COMMIT;