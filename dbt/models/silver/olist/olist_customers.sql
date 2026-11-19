-- models/silver/olist/olist_customers.sql
with src as (
    {{ latest_by_key(source('bronze', 'olist_customers'), ['customer_id']) }}
)
select
    customer_id,                         -- one per ORDER in Olist
    customer_unique_id,                  -- the real person
    lpad(trim(customer_zip_code_prefix), 5, '0')  as zip_code_prefix,
    {{ normalize_text('customer_city') }}         as city,
    upper(trim(customer_state))                   as state,
    _ingested_at
from src