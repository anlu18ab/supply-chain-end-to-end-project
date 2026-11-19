{% macro normalize_text(column_name) -%}
translate(
    lower(trim({{ column_name }})),
    'áàâãäéèêëíìîïóòôõöúùûüçñ',
    'aaaaaeeeeiiiiooooouuuucn'
)
{%- endmacro %}