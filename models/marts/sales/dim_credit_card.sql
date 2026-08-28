select
    credit_card_id,
    card_type
from {{ ref('stg_adventure_works__credit_card') }}