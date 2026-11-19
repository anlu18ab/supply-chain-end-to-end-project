select n
from (
    select count(*) as n
    from {{ ref('m5_sales_daily') }}
)
where n != 30490 * {{ var('m5_max_day', 1941) }}
