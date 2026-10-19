-- СТУДЕНТ. Блок А: виконайте три порівняння. Два останні — НАВМИСНО неправильні.

-- 1. Правильна сума лише з таблиці замовлень (без JOIN із позиціями):
SELECT currency, COUNT(*) AS orders, SUM(total_amount) AS correct_amount
FROM lab03_cf.v_period_orders WHERE order_status = 'delivered'
GROUP BY currency ORDER BY currency;

-- 2. Помилкова сума після прямого JOIN із core.order_items (розмноження суми замовлення на кількість позицій):
SELECT o.currency, COUNT(*) AS joined_rows, SUM(o.total_amount) AS wrong_amount
FROM lab03_cf.v_period_orders o JOIN core.order_items i ON i.order_id = o.order_id
WHERE o.order_status = 'delivered' GROUP BY o.currency ORDER BY o.currency;

-- 3. Хибна спроба "виправлення" через SUM(DISTINCT total_amount) (відкидає різні замовлення з однаковою сумою):
SELECT o.currency, SUM(DISTINCT o.total_amount) AS not_a_valid_fix
FROM lab03_cf.v_period_orders o JOIN core.order_items i ON i.order_id = o.order_id
WHERE o.order_status = 'delivered' GROUP BY o.currency ORDER BY o.currency;

-- Допоміжний запит для п. 2.2 (Ручна перевірка 2–3 доставлених замовлень однієї валюти):
-- Обирає 3 доставлені замовлення у UAH за звітний місяць, де принаймні одне має кілька позицій.
WITH sample_orders AS (
    SELECT o.order_id, o.total_amount, o.currency,
           COUNT(i.order_item_id) AS item_rows,
           COALESCE(SUM(i.quantity), 0) AS total_units
    FROM lab03_cf.v_period_orders o
             LEFT JOIN core.order_items i ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered' AND o.currency = 'UAH'
    GROUP BY o.order_id, o.total_amount, o.currency
    HAVING COUNT(i.order_item_id) > 1
    ORDER BY o.order_id
    LIMIT 3
)
SELECT
    order_id,
    currency,
    total_amount,
    item_rows AS positions_count,
    total_units AS sum_quantity,
    (total_amount * item_rows) AS duplicated_amount_after_join
FROM sample_orders;


-- Блок Б: Створення VIEW lab03_cf.v_daily_orders з трьома послідовними CTE.
-- Grain: report_date × merchant_id × currency.
CREATE OR REPLACE VIEW lab03_cf.v_daily_orders AS
WITH selected_orders AS (
    SELECT
        order_id,
        report_date,
        merchant_id,
        currency,
        total_amount
    FROM lab03_cf.v_period_orders
    WHERE order_status = 'delivered'
),
     items_by_order AS (
         SELECT
             order_id,
             SUM(quantity) AS units
         FROM core.order_items
         GROUP BY order_id
     ),
     orders_with_units AS (
         SELECT
             o.order_id,
             o.report_date,
             o.merchant_id,
             o.currency,
             o.total_amount,
             COALESCE(i.units, 0) AS units,
             i.order_id AS item_order_id
         FROM selected_orders o
                  LEFT JOIN items_by_order i ON i.order_id = o.order_id
     )
SELECT
    report_date,
    merchant_id,
    currency,
    COUNT(*) AS order_count,
    SUM(total_amount) AS order_amount,
    ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_order_amount,
    SUM(units) AS accepted_units,
    COUNT(*) FILTER (WHERE item_order_id IS NULL) AS orders_without_items
FROM orders_with_units
GROUP BY report_date, merchant_id, currency;


-- Перегляд перших 10 рядків створеного денного звіту (для п. 3.2):
SELECT *
FROM lab03_cf.v_daily_orders
ORDER BY report_date, merchant_id, currency
LIMIT 10;
