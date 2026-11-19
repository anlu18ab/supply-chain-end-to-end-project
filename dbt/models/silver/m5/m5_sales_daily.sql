-- models/silver/m5/m5_sales_daily.sql
{{ config(liquid_clustered_by=['store_id', 'sales_date']) }}

{#- Build the list of day columns (d_1 ... d_1941) from the live bronze table -#}
{% set day_cols = [] %}
{% if execute %}
  {% set cols = adapter.get_columns_in_relation(source('bronze', 'm5_sales_train_evaluation')) %}
  {% for c in cols %}
    {% if modules.re.match('^d_[0-9]+$', c.name) %}
      {% do day_cols.append(c.name) %}
    {% endif %}
  {% endfor %}
{% endif %}

with src as (
    {{ latest_by_key(source('bronze', 'm5_sales_train_evaluation'), ['id']) }}
),

unpivoted as (
    select
        id, item_id, dept_id, cat_id, store_id, state_id,
        stack(
            {{ day_cols | length }},
            {% for c in day_cols %}'{{ c }}', `{{ c }}`{% if not loop.last %}, {% endif %}{% endfor %}
        ) as (d, units_sold_raw)
    from src
)

select
    u.id                                          as series_id,
    u.item_id,
    u.dept_id,
    u.cat_id,
    u.store_id,
    u.state_id,
    c.calendar_date                               as sales_date,
    c.day_num,
    c.wm_yr_wk,
    try_cast(u.units_sold_raw as int)             as units_sold,
    p.sell_price,
    p.sell_price is not null                      as is_price_listed,
    c.event_name_1,
    c.event_type_1,
    c.event_name_2,
    c.event_type_2,
    case u.state_id
        when 'CA' then c.is_snap_ca
        when 'TX' then c.is_snap_tx
        when 'WI' then c.is_snap_wi
    end                                           as is_snap_day
from unpivoted as u
inner join {{ ref('m5_calendar') }} as c
    on u.d = c.d
left join {{ ref('m5_sell_prices') }} as p
    on  p.store_id  = u.store_id
    and p.item_id   = u.item_id
    and p.wm_yr_wk  = c.wm_yr_wk
where c.day_num <= {{ var('m5_max_day', 1941) }}