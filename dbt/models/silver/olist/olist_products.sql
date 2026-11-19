-- models/silver/olist/olist_products.sql
with products as (
    {{ latest_by_key(source('bronze', 'olist_products'), ['product_id']) }}
),
translation as (
    {{ latest_by_key(source('bronze', 'olist_product_category_name_translation'), ['product_category_name']) }}
)
select
    p.product_id,
    p.product_category_name                                                     as category_name_pt,
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category_name_en,
    try_cast(p.product_name_lenght as int)          as name_length,         -- sic: typo fixed
    try_cast(p.product_description_lenght as int)   as description_length,  -- sic: typo fixed
    try_cast(p.product_photos_qty as int)           as photos_qty,
    try_cast(p.product_weight_g as int)             as weight_g,
    try_cast(p.product_length_cm as int)            as length_cm,
    try_cast(p.product_height_cm as int)            as height_cm,
    try_cast(p.product_width_cm as int)             as width_cm,
    p._ingested_at
from products as p
left join translation as t
    on p.product_category_name = t.product_category_name