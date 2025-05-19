USE adashi_staging;

-- Query to Question 2
-- CTE to count transactions per user per month
WITH monthly_txns AS (
    SELECT 
        u.id AS user_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS txn_month,
        COUNT(s.id) AS txn_count
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s 
        ON s.owner_id = u.id AND s.confirmed_amount > 0
    GROUP BY u.id, txn_month
),
-- CTE to compute average monthly transactions for each user
avg_txn_per_user AS (
    SELECT 
        u.id AS user_id,
        u.first_name,
        u.last_name,
        IFNULL(AVG(m.txn_count), 0) AS avg_txn_per_month
    FROM users_customuser u
    LEFT JOIN monthly_txns m ON u.id = m.user_id
    GROUP BY u.id, u.first_name, u.last_name
),
-- CTE to assign frequency category based on avg monthly txn
categorized AS (
    SELECT 
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM avg_txn_per_user
)
-- Final grouping to get summary by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');