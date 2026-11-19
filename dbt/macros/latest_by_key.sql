{% macro latest_by_key(relation, key_columns) -%}
select *
from {{ relation }}
qualify row_number() over (
    partition by {{ key_columns | join(', ') }}
    order by _ingested_at desc, _source_file desc
) = 1
{%- endmacro %}