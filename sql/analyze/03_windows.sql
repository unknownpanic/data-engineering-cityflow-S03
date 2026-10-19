-- СТУДЕНТ. Напишіть два VIEW на вже наявних даних CityFlow.
-- Накопичувальна сума (running total) за кожним закладом та валютою вподовж місяця.
-- Джерело: lab03_cf.v_daily_orders (зберігаються всі денні рядки без згортання).
CREATE OR REPLACE VIEW lab03_cf.v_running_orders AS
SELECT
    report_date,
    merchant_id,
    currency,
    order_amount,
    SUM(order_amount) OVER (
        PARTITION BY merchant_id, currency
        ORDER BY report_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_amount
FROM lab03_cf.v_daily_orders;


-- 2. VIEW lab03_cf.v_latest_customer_order:
-- Останнє створене замовлення кожного клієнта у вибраному місяці (усі статуси).
-- За однакового created_at поле order_id DESC забезпечує детермінований вибір.
CREATE OR REPLACE VIEW lab03_cf.v_latest_customer_order AS
WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        merchant_id,
        created_at,
        order_status,
        currency,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY created_at DESC, order_id DESC
            ) AS rn
    FROM lab03_cf.v_period_orders
)
SELECT
    customer_id,
    order_id,
    merchant_id,
    created_at,
    order_status,
    currency,
    total_amount
FROM ranked_orders
WHERE rn = 1;


-- Перевірочні вибірки для звіту (п. 4.1 та п. 4.3):

-- A. Приклад накопичення для одного закладу та однієї валюти за кілька днів (п. 4.1):
WITH top_merchant AS (
    SELECT merchant_id, currency
    FROM lab03_cf.v_running_orders
    GROUP BY merchant_id, currency
    HAVING COUNT(*) >= 3
    ORDER BY COUNT(*) DESC, merchant_id, currency
    LIMIT 1
)
SELECT r.report_date, r.merchant_id, r.currency, r.order_amount, r.cumulative_amount
FROM lab03_cf.v_running_orders r
         JOIN top_merchant m USING (merchant_id, currency)
ORDER BY r.report_date;

-- B. Усі замовлення одного клієнта за місяць з номерами rn та вибраний рядок у v_latest_customer_order (п. 4.3):
WITH sample_customer AS (
    SELECT customer_id
    FROM lab03_cf.v_period_orders
    GROUP BY customer_id
    HAVING COUNT(*) >= 2
    ORDER BY COUNT(*) DESC, customer_id
    LIMIT 1
)
SELECT
    o.customer_id,
    o.order_id,
    o.merchant_id,
    o.created_at,
    o.order_status,
    o.currency,
    o.total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.created_at DESC, o.order_id DESC
        ) AS rn
FROM lab03_cf.v_period_orders o
         JOIN sample_customer c USING (customer_id)
ORDER BY rn;
