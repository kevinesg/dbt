{{ 
    config(
        materialized='incremental',
        unique_key='id'
    ) 
}}


SELECT l.*
FROM {{ ref('stg__finance__ledger') }} AS l
JOIN {{ ref('silver__finance__binary_type') }} AS b
    ON l.type = b.type
    AND b.binary_type = 'INCOME'

WHERE TRUE

    {% if is_incremental() %}

    AND l._inserted_at > (SELECT MAX(_inserted_at) FROM {{ this }})

    {% endif %}
