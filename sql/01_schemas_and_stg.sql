CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.runs (
    run_id SERIAL PRIMARY KEY,
    batch_id TEXT,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    status TEXT
);

CREATE TABLE IF NOT EXISTS audit.record_status (
    batch_id TEXT,
    source_file TEXT,
    source_row_number INT,
    business_key TEXT,
    status TEXT,
    reason_code TEXT
);

CREATE TABLE IF NOT EXISTS stg.customers (
    batch_id TEXT, source_file TEXT, source_row_number INT, loaded_at TIMESTAMPTZ DEFAULT NOW(),
    customer_id TEXT, full_name TEXT, email TEXT, phone TEXT, city TEXT, service_zone_id TEXT, registered_at TEXT, customer_status TEXT
);

CREATE TABLE IF NOT EXISTS stg.merchants (
    batch_id TEXT, source_file TEXT, source_row_number INT, loaded_at TIMESTAMPTZ DEFAULT NOW(),
    merchant_id TEXT, merchant_name TEXT, merchant_type TEXT, city TEXT, service_zone_id TEXT, opened_at TEXT, merchant_status TEXT
);

CREATE TABLE IF NOT EXISTS stg.products (
    batch_id TEXT, source_file TEXT, source_row_number INT, loaded_at TIMESTAMPTZ DEFAULT NOW(),
    product_id TEXT, merchant_id TEXT, product_name TEXT, category TEXT, unit_price_uah TEXT, is_active TEXT, updated_at TEXT
);

CREATE TABLE IF NOT EXISTS stg.orders (
    batch_id TEXT, source_file TEXT, source_row_number INT, loaded_at TIMESTAMPTZ DEFAULT NOW(),
    order_id TEXT, customer_id TEXT, merchant_id TEXT, created_at TEXT, order_status TEXT, currency TEXT, subtotal_amount TEXT, delivery_fee TEXT, discount_amount TEXT, total_amount TEXT
);

CREATE TABLE IF NOT EXISTS stg.order_items (
    batch_id TEXT, source_file TEXT, source_row_number INT, loaded_at TIMESTAMPTZ DEFAULT NOW(),
    order_item_id TEXT, order_id TEXT, product_id TEXT, quantity TEXT, unit_price TEXT, line_discount TEXT, line_total TEXT, currency TEXT
);
