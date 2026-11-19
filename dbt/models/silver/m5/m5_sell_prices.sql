-- models/silver/m5/m5_sell_prices.sql
with src as (
    {{ latest_by_key(source('bronze', 'm5_sell_prices'), ['store_id', 'item_id', 'wm_yr_wk']) }}
)

select
    store_id,
    item_id,
    try_cast(wm_yr_wk as int)           as wm_yr_wk,
    try_cast(sell_price as decimal(10,2)) as sell_price,
    _ingested_at
from src