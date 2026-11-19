-- models/silver/m5/m5_calendar.sql
with src as (
    {{ latest_by_key(source('bronze', 'm5_calendar'), ['d']) }}
)

select
    d,                                          -- 'd_1' ... 'd_1969', the join key to sales
    try_cast(substr(d, 3) as int)               as day_num,
    try_cast(`date` as date)                    as calendar_date,
    try_cast(wm_yr_wk as int)                   as wm_yr_wk,      -- Walmart week id, joins to prices
    weekday                                     as weekday_name,
    try_cast(wday as int)                       as weekday_num,   -- M5: 1 = Saturday
    try_cast(`month` as int)                    as month_num,
    try_cast(`year` as int)                     as year_num,
    event_name_1,
    event_type_1,
    event_name_2,
    event_type_2,
    coalesce(try_cast(snap_CA as int) = 1, false) as is_snap_ca,  -- food stamp days
    coalesce(try_cast(snap_TX as int) = 1, false) as is_snap_tx,
    coalesce(try_cast(snap_WI as int) = 1, false) as is_snap_wi,
    _ingested_at
from src