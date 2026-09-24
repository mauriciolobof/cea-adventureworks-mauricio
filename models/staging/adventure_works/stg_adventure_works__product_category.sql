with source as (
    select * from {{ source('adventure_works', 'production_productcategory') }}
),
renamed as (
    select
        productcategoryid as product_category_id,
        name,
        modifieddate      as modified_date
    from source
)
select * from renamed