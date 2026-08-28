with source as (
    select * from {{ source('adventure_works', 'humanresources_employee') }}
),
renamed as (
    select
        businessentityid as employee_id,
        jobtitle         as job_title,
        hiredate         as hire_date,
        modifieddate     as modified_date
    from source
)
select * from renamed