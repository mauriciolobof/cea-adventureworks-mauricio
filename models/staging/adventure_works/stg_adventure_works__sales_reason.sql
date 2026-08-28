with source as (
    select * from {{ source('adventure_works', 'sales_salesreason') }}
),
renamed as (
    select
        salesreasonid  as sales_reason_id,
        name,
        reasontype     as reason_type,
        modifieddate   as modified_date
    from source
)
select * from renamed