with source as (

    select *
    from {{ ref('raw_orders') }}

),

cleaned as (

    select
        order_id::integer as order_id,
        trim(customer_id)::text as customer_id,
        trim(store_id)::text as store_id,
        order_date::date as order_date,
        lower(trim(status))::text as order_status,
        coalesce(shipping_fee, 0)::numeric(12,2) as shipping_fee,
        upper(trim(currency))::text as currency

    from source

),

deduped as (

    select *

    from (
        select *,
            row_number() over (
                partition by order_id
                order by order_date desc
            ) as rn

        from cleaned

    ) ranked

    where rn = 1

)

select
    order_id,
    customer_id,
    store_id,
    order_date,
    order_status,
    shipping_fee,
    currency

from deduped