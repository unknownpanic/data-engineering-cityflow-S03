import pandas as pd
from sqlalchemy import create_engine
import uuid
import os
import sys

DB_URI = "postgresql://maxima:root@localhost:5432/cityflow"
engine = create_engine(DB_URI)
batch_id = str(uuid.uuid4())

expected_headers = {
    'customers': ['customer_id', 'full_name', 'email', 'phone', 'city', 'service_zone_id', 'registered_at', 'customer_status'],
    'merchants': ['merchant_id', 'merchant_name', 'merchant_type', 'city', 'service_zone_id', 'opened_at', 'merchant_status'],
    'products': ['product_id', 'merchant_id', 'product_name', 'category', 'unit_price_uah', 'is_active', 'updated_at'],
    'orders': ['order_id', 'customer_id', 'merchant_id', 'created_at', 'order_status', 'currency', 'subtotal_amount', 'delivery_fee', 'discount_amount', 'total_amount'],
    'order_items': ['order_item_id', 'order_id', 'product_id', 'quantity', 'unit_price', 'line_discount', 'line_total', 'currency']
}

files_to_load = {
    'customers': 'data/raw/base/customers.csv',
    'merchants': 'data/raw/base/merchants.csv',
    'products': 'data/raw/base/products.csv',
    'orders': 'data/raw/base/orders.csv',
    'order_items': 'data/raw/relational/order_items.csv'
}

print(f"Starting import. Batch ID: {batch_id}")

for table_name, file_path in files_to_load.items():
    if not os.path.exists(file_path):
        print(f"CRITICAL ERROR: Mandatory file {file_path} not found!")
        sys.exit(1)

    df = pd.read_csv(file_path, dtype=str)

    actual_headers = list(df.columns)
    if actual_headers != expected_headers[table_name]:
        print(f"CRITICAL ERROR: Invalid headers in {table_name}.")
        sys.exit(1)

    df['batch_id'] = batch_id
    df['source_file'] = file_path.split('/')[-1]
    df['source_row_number'] = range(1, len(df) + 1)

    df.to_sql(table_name, engine, schema='stg', if_exists='append', index=False)
    print(f"Loaded {len(df)} rows into stg.{table_name}")

print("Staging load complete!")