{{ 
    config(
        materialized='table'
    ) 
}}


SELECT DISTINCT
	type
    , CASE
    	WHEN type IN (
            'EXPENSES',
            'GIFT',
            'BILLS',
            'FAMILY SUPPORT',
            'SALARY DEDUCTION',
            'DONATION',
            'TAX',
            'CASH IN',
            'LOSS',
            'CONVERSION LOSS',
            'BET LOSS'
        ) THEN 'EXPENSES'
        WHEN type IN (
            'SALARY',
            'BONUS',
            'INTEREST',
            'CASHBACK',
            'CASH OUT',
            'ALLOWANCE',
            'SELL',
            'BET WIN'
        ) THEN 'INCOME'
        ELSE NULL
      END AS binary_type

FROM {{ ref('stg__finance__ledger') }}

ORDER BY binary_type