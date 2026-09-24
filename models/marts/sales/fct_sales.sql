with order_detail as (
    select * from {{ ref('stg_adventure_works__sales_order_detail') }}
),
order_header as (
    select * from {{ ref('stg_adventure_works__sales_order_header') }}
),
final as (
    select
        -- grão: 1 linha por item de pedido
        order_detail.sales_order_detail_id,

        -- FKs para as dimensões
        order_header.order_date            as date_key,
        order_header.customer_id,
        order_detail.product_id,
        order_header.sales_person_id,
        order_header.ship_to_address_id    as address_id,
        order_header.credit_card_id,

        -- dimensões degeneradas
        order_detail.sales_order_id,
        order_header.status,

        -- métricas
        order_detail.order_qty,
        order_detail.unit_price,
        order_detail.unit_price_discount,
        order_detail.unit_price * order_detail.order_qty as gross_amount,
        order_detail.unit_price * order_detail.order_qty * (1 - order_detail.unit_price_discount) as net_amount

    from order_detail
    inner join order_header on order_detail.sales_order_id = order_header.sales_order_id
)

select * from final