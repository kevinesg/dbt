{{ 
    config(
        materialized='table'
    ) 
}}


WITH laundry_expenses AS (
    SELECT
        date
        , SUM(cost) AS cost -- just in case there are multiple instances in one day;
                            -- the logic in the next CTE works under the assumption
                            -- that there is max one instance per day
    FROM {{ ref('silver__finance__ledger_expenses') }}
    WHERE item = 'LAUNDRY'
    GROUP BY 1
)


, base AS (
    SELECT
        d.date
        , e.cost
        , FIRST_VALUE(e.cost IGNORE NULLS) OVER (
            ORDER BY d.date
            ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
        ) AS next_cost
        , COUNT(e.cost) OVER (
            ORDER BY d.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) - COUNT(e.cost) OVER(
            ROWS BETWEEN CURRENT ROW AND CURRENT ROW
        ) AS group_id
        , COUNT(d.date) OVER (
            ORDER BY d.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_day_count
        , SUM(COALESCE(e.cost, 0)) OVER (
            ORDER BY d.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_cost
    FROM {{ ref('dates') }} AS d
    LEFT JOIN laundry_expenses AS e
        ON d.date = e.date
    WHERE d.date <= CURRENT_DATE('Asia/Manila') -- it doesn't make sense to have future dates here
)


SELECT
    date
    , ROUND(next_cost / COUNT(*) OVER (PARTITION BY group_id), 2) AS daily_cost
    , ROUND(running_total_cost / running_day_count, 2) AS average_daily_cost
FROM base
ORDER BY 1
