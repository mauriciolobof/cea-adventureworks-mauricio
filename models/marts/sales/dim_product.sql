with product as (
    select * from {{ ref('stg_adventure_works__product') }}
),
subcategory as (
    select * from {{ ref('stg_adventure_works__product_subcategory') }}
),
category as (
    select * from {{ ref('stg_adventure_works__product_category') }}
),
final as (
    select
        product.product_id,
        product.name          as product_name,
        product.product_number,
        product.color,
        product.list_price,
        product.standard_cost,
        subcategory.name      as product_subcategory_name,
        category.name         as product_category_name
    from product
    left join subcategory on product.product_subcategory_id = subcategory.product_subcategory_id
    left join category on subcategory.product_category_id = category.product_category_id
)
select * from final