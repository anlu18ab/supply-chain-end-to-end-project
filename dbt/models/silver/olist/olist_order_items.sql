-- models/silver/olist/olist_order_items.sql   (grain: order × item line)
with src as (
    {{ latest_by_key(source('bronze', 'olist_order_items'), ['order_id', 'order_item_id']) }}
)
select
    order_id,
    try_cast(order_item_id as int)                                  as order_item_number,
    product_id,
    seller_id,
    try_to_timestamp(shipping_limit_date, 'yyyy-MM-dd HH:mm:ss')    as shipping_limit_at,
    try_cast(price as decimal(12,2))                                as price,
    try_cast(freight_value as decimal(12,2))                        as freight_value,
    _ingested_at
from src