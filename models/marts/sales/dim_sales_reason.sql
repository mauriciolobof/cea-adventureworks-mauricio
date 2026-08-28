select
    sales_reason_id,
    name as sales_reason_name,
    reason_type
from {{ ref('stg_adventure_works__sales_reason') }}