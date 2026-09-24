with source as (
    select * from {{ source('adventure_works', 'person_countryregion') }}
),
renamed as (
    select
        -- fix conhecido: o código ISO da Namíbia é "NA", que o processo de
        -- ingestão interpretou como valor nulo. Ver nota no sources.yml.
        coalesce(countryregioncode, case when name = 'Namibia' then 'NA' end)
            as country_region_code,
        name,
        modifieddate as modified_date
    from source
)
select * from renamed