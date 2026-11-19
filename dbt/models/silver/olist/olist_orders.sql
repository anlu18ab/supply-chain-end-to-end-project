-- models/silver/olist/olist_orders.sql   (grain: one row per order)
with src as (
    {{ latest_by_key(source('bronze', 'olist_orders'), ['order_id']) }}
)
select
    order_id,
    customer_id,
    lower(trim(order_status))                                               as order_status,
    try_to_timestamp(order_purchase_timestamp,      'yyyy-MM-dd HH:mm:ss')  as purchased_at,
    try_to_timestamp(order_approved_at,             'yyyy-MM-dd HH:mm:ss')  as approved_at,
    try_to_timestamp(order_delivered_carrier_date,  'yyyy-MM-dd HH:mm:ss')  as carrier_picked_up_at,
    try_to_timestamp(order_delivered_customer_date, 'yyyy-MM-dd HH:mm:ss')  as delivered_to_customer_at,
    try_to_timestamp(order_estimated_delivery_date, 'yyyy-MM-dd HH:mm:ss')  as estimated_delivery_at,
    _ingested_at
from src