with source as (
    select * from {{ source('adventure_works', 'sales_salesperson') }}
),
renamed as (
    select
        businessentityid as sales_person_id,
        territoryid      as territory_id,
        salesquota       as sales_quota,
        bonus,
        commissionpct    as commission_pct,
        salesytd         as sales_ytd,
        saleslastyear    as sales_last_year,
        modifieddate     as modified_date
    from source
)
select * from renamed