BEGIN;
INSERT INTO core.customers (customer_id, full_name, city, registered_at) VALUES ('TEST-CUST', 'Test User', 'Lviv', NOW());
INSERT INTO core.orders (order_id, customer_id, merchant_id, created_at, total_amount) VALUES ('TEST-ORD', 'TEST-CUST', (SELECT merchant_id FROM core.merchants LIMIT 1), NOW(), 100);
-- Навмисна помилка:
INSERT INTO core.order_items (order_item_id, order_id, product_id, quantity, unit_price, line_total) VALUES ('TEST-ITEM', 'TEST-ORD', (SELECT product_id FROM core.products LIMIT 1), -1, 100, -100);
-- Після помилки:
ROLLBACK;

-- Запит поверне 0 рядків.
SELECT * FROM core.customers WHERE customer_id = 'TEST-CUST';