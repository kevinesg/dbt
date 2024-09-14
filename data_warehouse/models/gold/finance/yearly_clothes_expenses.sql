{{ 
    config(
        materialized='table'
    ) 
}}


SELECT
    EXTRACT(YEAR FROM date) AS year
    , SUM(cost) AS cost
FROM {{ ref('silver__finance__ledger_expenses') }}
WHERE TRUE
    AND NOT _is_deleted
    AND item = 'CLOTHES'
GROUP BY 1
