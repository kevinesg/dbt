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
GROUP BY 1,2,3