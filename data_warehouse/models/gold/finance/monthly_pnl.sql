{{ 
    config(
        materialized='table'
    ) 
}}


WITH monthly_expenses AS (
    SELECT
        year_month
        , ROUND(SUM(expenses), 2) AS expenses
    FROM {{ ref('silver__finance__monthly_expenses') }}
    GROUP BY 1
)


, monthly_income AS (
    SELECT
        year_month
        , ROUND(SUM(income), 2) AS income
    FROM {{ ref('silver__finance__monthly_income') }}
    GROUP BY 1
)


, base AS (
    SELECT
        e.year_month
        , IFNULL(e.expenses, 0) AS expenses
        , IFNULL(i.income, 0) AS income
        , ROUND(IFNULL(i.income, 0) - IFNULL(e.expenses, 0), 2) AS savings
    FROM monthly_expenses AS e
    LEFT OUTER JOIN monthly_income AS i
        ON e.year_month = i.year_month

    UNION DISTINCT

    SELECT
        i.year_month
        , IFNULL(e.expenses, 0) AS expenses
        , IFNULL(i.income, 0) AS income
        , ROUND(IFNULL(i.income, 0) - IFNULL(e.expenses, 0), 2) AS savings
    FROM monthly_expenses AS e
    RIGHT OUTER JOIN monthly_income AS i
        ON e.year_month = i.year_month
)


SELECT
    year_month
    , expenses
    , income
    , savings
    , ROUND(
        SUM(savings) OVER(
            ORDER BY year_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
        )
        , 2
      ) AS running_savings

FROM base
ORDER BY 1