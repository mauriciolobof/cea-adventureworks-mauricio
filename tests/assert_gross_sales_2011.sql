-- Teste de dado solicitado pelo CEO (Carlos): as vendas brutas de 2011 devem
-- bater com o valor auditado pela contabilidade: $12.646.112,16.
-- Convenção do dbt: um teste singular PASSA quando a query retorna 0 linhas.

with gross_sales as (

    select round(sum(unit_price * order_qty), 2) as total_gross_sales
    from {{ ref('fct_sales') }}
    where date_key between '2011-01-01' and '2011-12-31'

)

select *
from gross_sales
where abs(total_gross_sales - 12646112.16) > 0.01