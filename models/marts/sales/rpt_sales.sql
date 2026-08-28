{{ config(materialized='table') }}

with fact as (
    select * from {{ ref('fct_sales') }}
),
dt as (
    select * from {{ ref('dim_date') }}
),
customer as (
    select * from {{ ref('dim_customer') }}
),
product as (
    select * from {{ ref('dim_product') }}
),
geography as (
    select * from {{ ref('dim_geography') }}
),
salesperson as (
    select * from {{ ref('dim_salesperson') }}
),
credit_card as (
    select * from {{ ref('dim_credit_card') }}
),
reason_bridge as (
    select * from {{ ref('fct_sales_reason_bridge') }}
),
reason as (
    select * from {{ ref('dim_sales_reason') }}
),

final as (
    select
        fact.sales_order_detail_id,
        fact.sales_order_id,
        fact.status,

        dt.date_day             as order_date,
        dt.year                 as order_year,
        dt.month                as order_month,
        dt.month_name           as order_month_name,

        customer.customer_id,
        customer.customer_name,
        customer.customer_type,

        product.product_id,
        product.product_name,
        product.product_category_name,
        product.product_subcategory_name,

        geography.city,
        geography.state_province_name,
        geography.country_region_name,

        salesperson.sales_person_id,
        salesperson.salesperson_name,

        credit_card.card_type,

        -- motivo de venda: se o pedido tiver mais de 1 motivo, esta linha se
        -- repete uma vez por motivo (atribuição múltipla intencional — ver
        -- nota em fct_sales_reason_bridge.sql). Ao somar "valor total
        -- negociado" SEM filtrar por motivo, o total fica inflado pra pedidos
        -- multi-motivo — por isso, pra totais gerais (série temporal, top
        -- clientes, top cidades), prefira agregações que não passem por essa
        -- coluna sem um filtro de motivo aplicado.
        reason.sales_reason_id,
        reason.sales_reason_name,

        fact.order_qty,
        fact.unit_price,
        fact.unit_price_discount,
        fact.gross_amount,
        fact.net_amount

    from fact
    left join dt             on fact.date_key        = dt.date_day
    left join customer       on fact.customer_id     = customer.customer_id
    left join product        on fact.product_id      = product.product_id
    left join geography      on fact.address_id      = geography.address_id
    left join salesperson    on fact.sales_person_id = salesperson.sales_person_id
    left join credit_card    on fact.credit_card_id  = credit_card.credit_card_id
    left join reason_bridge  on fact.sales_order_id  = reason_bridge.sales_order_id
    left join reason         on reason_bridge.sales_reason_id = reason.sales_reason_id
)

select * from final