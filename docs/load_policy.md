# Політика завантаження та Source-to-Target Mapping

## Правила валідації
1. **Типи та порожні значення:** Усі ідентифікатори зберігаються як `TEXT`, суми як `NUMERIC(12,2)`, дати конвертуються у `TIMESTAMPTZ`. Порожні первинні ключі відхиляються.
2. **Дати:** Записи з невалідним форматом дати (напр., 2026-19-45) відхиляються регулярним виразом під час публікації.
3. **Суми й категорії:** Активний товар (`is_active = true`) з ціною `<= 0` відхиляється. Кількість товарів (`quantity`) у `order_items` строго `> 0`.
4. **Зв'язки:** Перенесення дочірніх таблиць відбувається через `IN` (перевірка наявності ID в батьківській `core` таблиці).

## Source-to-Target Mapping
| Джерело (Staging) | Цільова таблиця (Core) | Трансформація / Правила |
| :--- | :--- | :--- |
| `stg.customers` | `core.customers` | `registered_at` (CAST to TIMESTAMPTZ). Regex перевірка дати. |
| `stg.merchants` | `core.merchants` | `opened_at` (CAST to TIMESTAMPTZ). |
| `stg.products` | `core.products` | `unit_price_uah` (NUMERIC). Блокування `<=0` для активних. |
| `stg.orders` | `core.orders` | `created_at` (TIMESTAMPTZ). Regex перевірка дати. |
| `stg.order_items` | `core.order_items` | `quantity` (INT) > 0, `unit_price` (NUMERIC) >= 0. |