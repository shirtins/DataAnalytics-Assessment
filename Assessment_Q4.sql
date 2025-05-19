USE adashi_staging;

-- Query to Question 4
-- Step 1: Summarize transaction data for each user
WITH txn_summary AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- Account tenure in months
        COUNT(s.id) AS txn_count,  -- Number of transactions
        SUM(s.confirmed_amount) / 100 AS total_transaction_value_naira,  -- Convert kobo to Naira
        AVG(s.confirmed_amount) / 100 AS avg_transaction_value_naira     -- Average transaction value in Naira
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s 
        ON s.owner_id = u.id AND s.confirmed_amount > 0  -- Consider only confirmed inflow transactions
    GROUP BY u.id, u.first_name, u.last_name, u.date_joined
),

-- Step 2: Calculate Estimated CLV using the simplified model
clv_calc AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        txn_count AS total_transactions,
        ROUND(
            CASE 
                WHEN tenure_months > 0 THEN (total_transaction_value_naira / tenure_months) * 12 * (avg_transaction_value_naira * 0.001)
                ELSE 0
            END,
            2
        ) AS estimated_clv  -- CLV = (total_txn_value / tenure) * 0.012 * avg_txn_value
    FROM txn_summary
)

-- Step 3: Final output ordered by CLV descending
SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;