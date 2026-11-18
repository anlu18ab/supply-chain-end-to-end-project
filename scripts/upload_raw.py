from datetime import date
from pathlib import Path
from databricks.sdk import WorkspaceClient

CATALOG = "supply_chain_dev"
ROOT = f"/Volumes/{CATALOG}/landing/raw"
today = date.today().isoformat()
w = WorkspaceClient()

# (local file, source, entity)
FILES = [
    ("data/raw/m5/calendar.csv", "m5", "calendar"),
    ("data/raw/m5/sales_train_evaluation.csv", "m5", "sales_train_evaluation"),
    ("data/raw/m5/sell_prices.csv", "m5", "sell_prices"),
    ("data/raw/olist/olist_orders_dataset.csv", "olist", "orders"),
    ("data/raw/olist/olist_order_items_dataset.csv", "olist", "order_items"),
    ("data/raw/olist/olist_order_payments_dataset.csv", "olist", "order_payments"),
    ("data/raw/olist/olist_order_reviews_dataset.csv", "olist", "order_reviews"),
    ("data/raw/olist/olist_customers_dataset.csv", "olist", "customers"),
    ("data/raw/olist/olist_sellers_dataset.csv", "olist", "sellers"),
    ("data/raw/olist/olist_products_dataset.csv", "olist", "products"),
    ("data/raw/olist/olist_geolocation_dataset.csv", "olist", "geolocation"),
    ("data/raw/olist/product_category_name_translation.csv", "olist",
     "product_category_name_translation"),
]

for local, source, entity in FILES:
    p = Path(local)
    target = f"{ROOT}/{source}/{entity}/ingest_date={today}/{p.name}"
    with p.open("rb") as f:
        w.files.upload(target, f, overwrite=False)  # raw is immutable
    print("uploaded", target)