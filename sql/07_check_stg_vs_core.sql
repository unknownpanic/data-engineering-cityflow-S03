-- Звірка рядків і сум за currency до/після публікації (STG vs CORE)
-- Порівнює кількість та суму валідних записів у stg із завантаженими у core.

SELECT
    c.currency,
    COUNT(c.order_id) AS core_rows,
    SUM(c.total_amount) AS core_total_sum,

    -- Рахуємо унікальні замовлення з stg, які пройшли всі перевірки
    (SELECT COUNT(DISTINCT s.order_id)
     FROM stg.orders s
     WHERE s.currency = c.currency
       AND s.created_at ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])'
       AND s.customer_id IN (SELECT customer_id FROM core.customers)
       AND s.merchant_id IN (SELECT merchant_id FROM core.merchants)
    ) AS stg_accepted_rows,

    -- Рахуємо суму для цих унікальних валідних замовлень
    (SELECT SUM(CAST(total_amount AS NUMERIC))
     FROM (
              SELECT DISTINCT ON (order_id) total_amount
              FROM stg.orders s2
              WHERE s2.currency = c.currency
                AND s2.created_at ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])'
                AND s2.customer_id IN (SELECT customer_id FROM core.customers)
                AND s2.merchant_id IN (SELECT merchant_id FROM core.merchants)
          ) AS unique_valid_orders
    ) AS stg_accepted_sum

FROM core.orders c
GROUP BY c.currency;