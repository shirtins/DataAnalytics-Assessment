USE adashi_staging;

-- Query to Question 3
-- Step 1: Aggregate without CASE logic
WITH raw_latest_txn AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        p.is_regular_savings,
        p.is_a_fund,
        MAX(s.transaction_date) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s 
        ON s.plan_id = p.id AND s.confirmed_amount > 0
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
    GROUP BY p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
)
-- Step 2: Compute type label after aggregation
SELECT
    plan_id,
    owner_id,
    CASE 
        WHEN is_regular_savings = 1 THEN 'Savings'
        WHEN is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM raw_latest_txn
WHERE last_transaction_date IS NULL 
   OR DATEDIFF(CURDATE(), last_transaction_date) > 365 
ORDER BY inactivity_days DESC;