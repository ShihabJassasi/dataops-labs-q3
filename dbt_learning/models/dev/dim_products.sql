{{ config(materialized='table') }}

with products as (

    select *
    from {{ ref('stg_products') }}

),

final as (

    select
        product_id,
        product_name,
        category,
        subcategory,
        list_price,
        cost_price,
        list_price - cost_price as unit_margin,
        currency,
        is_active,
        launch_date
    from products

)

select *
from final