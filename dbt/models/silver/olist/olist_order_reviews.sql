-- models/silver/olist/olist_order_reviews.sql   (grain: review × order)
-- review_id alone is NOT unique in the raw data, so the key is the pair.
with src as (
    {{ latest_by_key(source('bronze', 'olist_order_reviews'), ['review_id', 'order_id']) }}
)
select
    review_id,
    order_id,
    try_cast(review_score as int)                                           as review_score,
    review_comment_title                                                    as comment_title,
    review_comment_message                                                  as comment_message,
    try_to_timestamp(review_creation_date,  'yyyy-MM-dd HH:mm:ss')         as review_created_at,
    try_to_timestamp(review_answer_timestamp, 'yyyy-MM-dd HH:mm:ss')        as review_answered_at,
    _ingested_at
from src