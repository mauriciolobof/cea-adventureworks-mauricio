with source as (
    select * from {{ source('adventure_works', 'production_product') }}
),
renamed as (
    select
        productid             as product_id,
        name,
        productnumber         as product_number,
        color,
        listprice             as list_price,
        standardcost          as standard_cost,
        productsubcategoryid  as product_subcategory_id,
        sellstartdate         as sell_start_date,
        sellenddate           as sell_end_date,
        discontinueddate      as discontinued_date,
        modifieddate          as modified_date
    from source
)
select * from renamed