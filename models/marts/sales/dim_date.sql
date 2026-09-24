{{ config(materialized='table') }}

with date_spine as (
    select explode(sequence(to_date('2003-01-01'), to_date('2016-12-31'), interval 1 day)) as date_day
),

final as (
    select
        date_day,
        year(date_day)               as year,
        quarter(date_day)            as quarter,
        month(date_day)              as month,
        date_format(date_day, 'MMMM') as month_name,
        day(date_day)                as day_of_month,
        dayofweek(date_day)          as day_of_week,
        date_format(date_day, 'EEEE') as day_name,
        weekofyear(date_day)         as week_of_year
    from date_spine
)

select * from final