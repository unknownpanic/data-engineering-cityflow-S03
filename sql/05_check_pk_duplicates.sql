-- Перевірка на відсутність дублікатів первинних ключів (PK) у кожній core-таблиці
-- Очікуваний результат: 0 для кожної таблиці.

SELECT 'customers' AS table_name, COUNT(*) AS duplicate_pks
FROM (SELECT customer_id FROM core.customers GROUP BY customer_id HAVING COUNT(*) > 1) c
UNION ALL
SELECT 'merchants', COUNT(*)
FROM (SELECT merchant_id FROM core.merchants GROUP BY merchant_id HAVING COUNT(*) > 1) m
UNION ALL
SELECT 'products', COUNT(*)
FROM (SELECT product_id FROM core.products GROUP BY product_id HAVING COUNT(*) > 1) p
UNION ALL
SELECT 'orders', COUNT(*)
FROM (SELECT order_id FROM core.orders GROUP BY order_id HAVING COUNT(*) > 1) o
UNION ALL
SELECT 'order_items', COUNT(*)
FROM (SELECT order_item_id FROM core.order_items GROUP BY order_item_id HAVING COUNT(*) > 1) oi;