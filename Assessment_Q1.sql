USE adashi_staging;

-- Query to Question 1
-- Step 1: Get all plans with confirmed deposits and classify by type
WITH funded_plans AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        p.is_regular_savings,
        p.is_a_fund,
        SUM(s.confirmed_amount) / 100.0 AS total_deposit -- concerts kobo to naira
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.plan_id = p.id
    WHERE s.confirmed_amount > 0
    GROUP BY p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
),

-- Step 2: Aggregate per user and count plan types
user_summary AS (
    SELECT
        owner_id,
        COUNT(CASE WHEN is_regular_savings = 1 THEN 1 END) AS savings_count,
        COUNT(CASE WHEN is_a_fund = 1 THEN 1 END) AS investment_count,
        SUM(total_deposit) AS total_deposits
    FROM funded_plans
    GROUP BY owner_id
)

-- Step 3: Filter users with both plan types and join names
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name, 
    us.savings_count,
    us.investment_count,
    us.total_deposits
FROM user_summary us
JOIN users_customuser u ON u.id = us.owner_id
WHERE us.savings_count > 0 AND us.investment_count > 0
ORDER BY us.total_deposits DESC;
