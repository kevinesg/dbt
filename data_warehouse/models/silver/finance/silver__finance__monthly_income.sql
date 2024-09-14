{{ 
    config(
        materialized='table'
    ) 
}}


SELECT
    year_month
    , type
    , item
    , SUM(cost) AS income
FROM {{ ref('silver__finance__ledger_income') }}
WHERE NOT _is_deleted
GROUP BY 1,2,3