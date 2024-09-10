{{ 
    config(
        materialized='table'
    ) 
}}


SELECT
    year_month
    , type
    , item
    , SUM(cost) AS expenses
FROM {{ ref('silver__finance__ledger_expenses') }}
GROUP BY 1,2,3