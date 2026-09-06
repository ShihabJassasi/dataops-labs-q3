with item_rollup as (

    select
        order_id,
        count(*) as num_line_items,
        sum(quantity) as total_quantity,
        sum(net_amount) as net_revenue

    from {{ ref('fct_order_items') }}

    group by order_id

),

orders as (

    select
        order_id,
        customer_id,
        store_id,
        order_date,
        shipping_fee

    from {{ ref('stg_orders') }}

)

select
    o.order_id,
    o.customer_id,
    o.store_id,
    o.order_date,

    coalesce(i.num_line_items, 0) as num_line_items,
    coalesce(i.total_quantity, 0) as total_quantity,
    coalesce(i.net_revenue, 0) as net_revenue,

    o.shipping_fee,

    coalesce(i.net_revenue, 0) + coalesce(o.shipping_fee, 0)
        as order_total

from orders o

left join item_rollup i
    on o.order_id = i.order_id