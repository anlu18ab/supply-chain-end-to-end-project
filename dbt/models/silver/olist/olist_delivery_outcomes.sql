-- models/silver/olist/olist_delivery_outcomes.sql   (grain: one row per order)
with orders as (
    select * from {{ ref('olist_orders') }}
),

classified as (
    select
        order_id,
        order_status,
        purchased_at,
        delivered_to_customer_at,
        estimated_delivery_at,
        case
            when order_status = 'canceled'    then 'canceled'
            when order_status = 'unavailable' then 'unavailable'
            when order_status = 'delivered' and delivered_to_customer_at is null
                 then 'unknown'
            when order_status = 'delivered'
                 and date(delivered_to_customer_at) > date(estimated_delivery_at)
                 then 'late'
            when order_status = 'delivered' then 'on_time'
            else 'in_progress'
        end as delivery_outcome
    from orders
)

select
    order_id,
    order_status,
    purchased_at,
    delivered_to_customer_at,
    estimated_delivery_at,
    delivery_outcome,
    case
        when delivery_outcome = 'late'
        then datediff(date(delivered_to_customer_at), date(estimated_delivery_at))
        when delivery_outcome = 'on_time'
        then 0
    end as days_late,
    case
        when delivery_outcome in ('late', 'canceled', 'unavailable') then 1
        when delivery_outcome = 'on_time'                            then 0
    end as is_delivery_failure
from classified