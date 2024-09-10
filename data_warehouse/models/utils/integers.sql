{{
    config(
        materialized='table'
    )
}}


WITH integers AS (
    SELECT GENERATE_ARRAY(0, 100000) AS nums
)

SELECT n
FROM integers
JOIN UNNEST(integers.nums) AS n