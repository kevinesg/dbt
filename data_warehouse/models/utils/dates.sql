{{
    config(
        materialized='table'
    )
}}


SELECT
    DATE_ADD(CAST('2022-01-01' AS DATE), INTERVAL i.n DAY) AS date
FROM {{ ref('integers') }} AS i
WHERE i.n <= 3000 -- arbitrary upperbound since higher/future dates aren't really needed yet