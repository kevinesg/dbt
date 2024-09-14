{{ 
    config(
        materialized='table'
    ) 
}}


SELECT
    EXTRACT(YEAR FROM date) AS year
    , item
    , SUM(cost) AS cost
FROM {{ ref('silver__finance__ledger_expenses') }}
WHERE TRUE
    AND NOT _is_deleted
    AND item IN ('MASSAGE', 'MASSAGE CHAIR')
GROUP BY 1,2
