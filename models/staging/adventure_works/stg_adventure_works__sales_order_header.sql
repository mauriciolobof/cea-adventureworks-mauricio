with source as (

    select * from {{ source('adventure_works', 'sales_salesorderheader') }}

),

renamed as (

    select
        salesorderid       as sales_order_id,
        customerid          as customer_id,
        salespersonid       as sales_person_id,
        billtoaddressid     as bill_to_address_id,
        shiptoaddressid     as ship_to_address_id,
        creditcardid        as credit_card_id,
        orderdate           as order_date,
        duedate             as due_date,
        shipdate             as ship_date,
        status,
        subtotal,
        taxamt              as tax_amt,
        freight,
        totaldue             as total_due,
        modifieddate         as modified_date

    from source

)

select * from renamed