with customer as (
    select * from {{ ref('stg_adventure_works__customer') }}
),
person as (
    select * from {{ ref('stg_adventure_works__person') }}
),
final as (
    select
        customer.customer_id,
        customer.person_id,
        customer.store_id,
        concat_ws(' ', person.first_name, person.last_name) as customer_name,
        case when customer.store_id is not null then 'Store' else 'Individual' end as customer_type
    from customer
    left join person on customer.person_id = person.person_id
)
select * from final