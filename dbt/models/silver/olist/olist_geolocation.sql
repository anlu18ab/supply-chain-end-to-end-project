-- models/silver/olist/olist_geolocation.sql   (grain: one row per zip prefix)
-- No latest_by_key here: duplicates per zip are expected in this file.
-- Averages and "most frequent value" are unaffected if a file is re-delivered.
with typed as (
    select
        lpad(trim(geolocation_zip_code_prefix), 5, '0')  as zip_code_prefix,
        try_cast(geolocation_lat as double)              as lat,
        try_cast(geolocation_lng as double)              as lng,
        {{ normalize_text('geolocation_city') }}         as city,
        upper(trim(geolocation_state))                   as state
    from {{ source('bronze', 'olist_geolocation') }}
),

flagged as (
    select
        *,
        -- rough bounding box of Brazil; points outside are bad data
        coalesce(lat between -34 and 6 and lng between -74 and -34, false) as is_in_brazil
    from typed
),

coords as (
    select
        zip_code_prefix,
        avg(case when is_in_brazil then lat end) as lat,
        avg(case when is_in_brazil then lng end) as lng,
        count(*)                                 as source_row_count
    from flagged
    group by zip_code_prefix
),

modal_city as (
    select zip_code_prefix, city, state
    from (
        select zip_code_prefix, city, state, count(*) as n
        from typed
        group by zip_code_prefix, city, state
    )
    qualify row_number() over (partition by zip_code_prefix order by n desc, city) = 1
)

select
    c.zip_code_prefix,
    c.lat,
    c.lng,
    m.city,
    m.state,
    c.source_row_count
from coords as c
inner join modal_city as m using (zip_code_prefix)