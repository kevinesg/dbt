{% test is_fresh(model, column_name, interval) %}

WITH base AS (
    -- Check if the model is fresh based on a threshold
    SELECT
        MAX(TIMESTAMP({{ column_name }})) >= CURRENT_TIMESTAMP() - INTERVAL {{ interval }} AS is_fresh
    FROM {{ model }}
)

SELECT TIMESTAMP({{ column_name }})
FROM {{ model }}
WHERE TIMESTAMP({{ column_name }}) >=
    CASE
        WHEN (SELECT is_fresh FROM base) THEN CURRENT_TIMESTAMP() -- will give 0 rows
        ELSE TIMESTAMP('1000-01-01 00:00:00') -- will give all rows
    END

{% endtest %}