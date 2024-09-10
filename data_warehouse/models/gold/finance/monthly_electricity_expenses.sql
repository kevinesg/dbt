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
    AND item = 'ELECTRICITY BILL'
GROUP BY 1
