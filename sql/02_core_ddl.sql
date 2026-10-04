DROP TABLE IF EXISTS core.order_items CASCADE;
DROP TABLE IF EXISTS core.orders CASCADE;
DROP TABLE IF EXISTS core.products CASCADE;
DROP TABLE IF EXISTS core.merchants CASCADE;
DROP TABLE IF EXISTS core.customers CASCADE;

CREATE TABLE core.customers (
    customer_id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    city TEXT,
    registered_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE core.merchants (
    merchant_id TEXT PRIMARY KEY,
    merchant_name TEXT NOT NULL,
    city TEXT,
    opened_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE core.products (
    product_id TEXT PRIMARY KEY,
    merchant_id TEXT REFERENCES core.merchants(merchant_id),
    product_name TEXT NOT NULL,
    unit_price_uah NUMERIC(12,2) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE core.orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.customers(customer_id),
    merchant_id TEXT REFERENCES core.merchants(merchant_id),
    created_at TIMESTAMPTZ NOT NULL,
    order_status TEXT,
    currency TEXT,
    subtotal_amount NUMERIC(12,2),
    delivery_fee NUMERIC(12,2),
    discount_amount NUMERIC(12,2),
    total_amount NUMERIC(12,2)
);

CREATE TABLE core.order_items (
    order_item_id TEXT PRIMARY KEY,
    order_id TEXT REFERENCES core.orders(order_id),
    product_id TEXT REFERENCES core.products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    line_discount NUMERIC(12,2) CHECK (line_discount >= 0),
    line_total NUMERIC(12,2) NOT NULL,
    currency TEXT
);
