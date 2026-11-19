-- models/silver/olist/olist_order_payments.sql   (grain: order × payment sequence)
with src as (
    {{ latest_by_key(source('bronze', 'olist_order_payments'), ['order_id', 'payment_sequential']) }}
)
select
    order_id,
    try_cast(payment_sequential as int)         as payment_sequence,
    lower(trim(payment_type))                   as payment_type,
    try_cast(payment_installments as int)       as installments,
    try_cast(payment_value as decimal(12,2))    as payment_value,
    _ingested_at
from src