{{ 
    config(
        materialized='table'
    ) 
}}


SELECT
    year_month
    , SUM(cost) AS cost
FROM {{ ref('silver__finance__ledger_expenses') }}
WHERE TRUE
    AND item IN ('FOOD', 'GROCERY')
GROUP BY 1
