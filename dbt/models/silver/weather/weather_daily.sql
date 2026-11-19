-- models/silver/weather/weather_daily.sql   (grain: state × day)
with exploded as (
    select
        _state                                          as state_id,
        timezone                                        as timezone_name,
        p.day_str,
        daily.temperature_2m_max[p.pos]                 as temp_max_raw,
        daily.temperature_2m_min[p.pos]                 as temp_min_raw,
        daily.precipitation_sum[p.pos]                  as precipitation_raw,
        _ingested_at,
        _source_file
    from {{ source('bronze', 'open_meteo_daily') }}
    lateral view posexplode(daily.time) p as pos, day_str
),

deduped as (
    select *
    from exploded
    qualify row_number() over (
        partition by state_id, day_str
        order by _ingested_at desc, _source_file desc
    ) = 1
)

select
    state_id,
    try_cast(day_str as date)               as weather_date,
    try_cast(temp_max_raw as double)        as temp_max_c,
    try_cast(temp_min_raw as double)        as temp_min_c,
    try_cast(precipitation_raw as double)   as precipitation_mm,
    timezone_name,
    _ingested_at
from deduped