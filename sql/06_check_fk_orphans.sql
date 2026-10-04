-- Перевірка на відсутність порушень FK
-- Очікуваний результат: 0 для кожного зв'язку.

SELECT 'orders -> customers' AS fk_relation, COUNT(*) AS missing_fks
FROM core.orders WHERE customer_id NOT IN (SELECT customer_id FROM core.customers)
UNION ALL
SELECT 'orders -> merchants', COUNT(*)
FROM core.orders WHERE merchant_id NOT IN (SELECT merchant_id FROM core.merchants)
UNION ALL
SELECT 'products -> merchants', COUNT(*)
FROM core.products WHERE merchant_id NOT IN (SELECT merchant_id FROM core.merchants)
UNION ALL
SELECT 'order_items -> orders', COUNT(*)
FROM core.order_items WHERE order_id NOT IN (SELECT order_id FROM core.orders)
UNION ALL
SELECT 'order_items -> products', COUNT(*)
FROM core.order_items WHERE product_id NOT IN (SELECT product_id FROM core.products);