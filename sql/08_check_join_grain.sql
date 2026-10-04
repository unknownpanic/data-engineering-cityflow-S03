-- Вирішення проблеми завищеної суми при JOIN (Рівень деталізації)
-- Згортаємо деталізацію позицій до рівня замовлення перед з'єднанням таблиць.

-- Неправильна сумма
SELECT
    o.currency,
    SUM(o.total_amount) AS inflated_total_amount
FROM core.orders o
         JOIN core.order_items oi ON o.order_id = oi.order_id
GROUP BY o.currency;

-- Правильна сумма
WITH order_level_items AS (
    SELECT
        order_id,
        SUM(line_total) AS items_sum
    FROM core.order_items
    GROUP BY order_id
)
SELECT
    o.currency,
    SUM(o.total_amount) AS correct_order_total,
    SUM(i.items_sum) AS correct_items_total
FROM core.orders o
         JOIN order_level_items i ON o.order_id = i.order_id
GROUP BY o.currency;