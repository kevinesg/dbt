{{ 
    config(
        materialized='incremental',
        unique_key='id',
        post_hook="""
            DELETE FROM {{ this }}
            WHERE _is_deleted
        """
    ) 
}}


SELECT
    id
    , year_month
    , `to`
    , cost
    , source
    , _inserted_at
    , _is_deleted
FROM {{ ref('silver__finance__ledger_expenses') }}
WHERE TRUE
    AND item = 'SUBSCRIPTION'

    {% if is_incremental() %}

    AND _inserted_at > (SELECT MAX(_inserted_at) FROM {{ this }})

    {% endif %}
