-- Tabela ponte (factless fact): 1 linha por combinação pedido x motivo de venda.
-- Não junte isso à fct_sales pra somar quantidade/valor sem cuidado — como ~19%
-- dos pedidos têm mais de um motivo, a soma vai contar o mesmo item mais de uma
-- vez (uma vez por motivo do pedido). É esperado e intencional: cada motivo do
-- pedido "reivindica" a quantidade inteira dele (atribuição múltipla), útil pra
-- responder "quanto foi vendido com influência do motivo X", mas não soma pro
-- total geral de vendas.

select
    concat(cast(sales_order_id as string), '-', cast(sales_reason_id as string)) as sales_order_reason_key,
    sales_order_id,
    sales_reason_id
from {{ ref('stg_adventure_works__sales_order_header_sales_reason') }}