with salesperson as (
    select * from {{ ref('stg_adventure_works__salesperson') }}
),
employee as (
    select * from {{ ref('stg_adventure_works__employee') }}
),
person as (
    select * from {{ ref('stg_adventure_works__person') }}
),
final as (
    select
        salesperson.sales_person_id,
        concat_ws(' ', person.first_name, person.last_name) as salesperson_name,
        employee.job_title,
        salesperson.sales_quota,
        salesperson.sales_ytd,
        salesperson.sales_last_year
    from salesperson
    left join employee on salesperson.sales_person_id = employee.employee_id
    left join person on salesperson.sales_person_id = person.person_id
)
select * from final