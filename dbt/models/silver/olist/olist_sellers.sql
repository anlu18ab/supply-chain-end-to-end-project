-- models/silver/olist/olist_sellers.sql
with src as (
    {{ latest_by_key(source('bronze', 'olist_sellers'), ['seller_id']) }}
)
select
    seller_id,
    lpad(trim(seller_zip_code_prefix), 5, '0')  as zip_code_prefix,
    {{ normalize_text('seller_city') }}         as city,
    upper(trim(seller_state))                   as state,
    _ingested_at
from src