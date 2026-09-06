{{ config(
    materialized='incremental',
    unique_key='order_item_id'
) }}

with order_items as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        discount_pct
    from {{ ref('stg_order_items') }}

    {% if is_incremental() %}

    where order_item_id > (
        select coalesce(max(order_item_id), 0)
        from {{ this }}
    )

    {% endif %}

),

orders as (

    select
        order_id,
        customer_id,
        store_id,
        order_date,
        order_status
    from (

        select
            order_id,
            customer_id,
            store_id,
            order_date,
            order_status,
            row_number() over (
                partition by order_id
                order by order_id
            ) as rn

        from {{ ref('stg_orders') }}

    ) deduplicated_orders

    where rn = 1

),

products as (

    select
        product_id,
        cost_price
    from {{ ref('stg_products') }}

)

select
    oi.order_item_id,
    oi.order_id,
    oi.product_id,

    o.customer_id,
    o.store_id,
    o.order_date,
    o.order_status,

    oi.quantity,
    oi.unit_price,
    oi.discount_pct,

    p.cost_price,

    oi.quantity * oi.unit_price
        as gross_amount,

    oi.quantity * oi.unit_price * oi.discount_pct / 100.0
        as discount_amount,

    {{ net_amount('oi.quantity', 'oi.unit_price', 'oi.discount_pct') }}::numeric(12,2)
        as net_amount,

    oi.quantity * p.cost_price
        as total_cost,

    (
        {{ net_amount('oi.quantity', 'oi.unit_price', 'oi.discount_pct') }}
        -
        oi.quantity * p.cost_price
    ) as margin

from order_items oi

left join orders o
    on oi.order_id = o.order_id

left join products p
    on oi.product_id = p.product_id