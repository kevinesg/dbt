{{ 
    config(
        materialized='incremental',
        unique_key='id'
    ) 
}}


SELECT
    id
    , CONCAT(CAST(year AS STRING), '-', LPAD(CAST(month AS STRING), 2, '0')) AS year_month
    , DATE(year, month, day) AS date
    , item
    , type
    , cost
    , `to`
    , store
    , source
    , TIMESTAMP_ADD(PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", created_at), INTERVAL -8 HOUR) AS _created_at
    , TIMESTAMP_ADD(PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", updated_at), INTERVAL -8 HOUR) AS _updated_at
    , _inserted_at
    , _is_deleted
FROM {{ source('finance', 'finance__ledger') }}

WHERE TRUE

    {% if is_incremental() %}

    AND _inserted_at > (SELECT MAX(_inserted_at) FROM {{ this }})

    {% endif %}
