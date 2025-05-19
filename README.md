#  Cowrywise Data Analyst Assessment – SQL Project

This repository contains SQL solutions to a data analyst assessment by **Cowrywise**, a fintech company helping people build wealth through digital savings and investment products.

Each query solves a real-world business case, reflecting the needs of teams like Marketing, Finance, and Operations. The assessment tested proficiency in writing **accurate, efficient, complete and readable SQL queries**.

---

##  Project Context

As a data analyst candidate, I was given access to a relational database with:

-  `users_customuser` — customer demographic and contact information  
-  `plans_plan` — records of plans created by customers  
-  `savings_savingsaccount` — records of deposit transactions
-  `withdrwals_withdrawal` - records of withdrawal transactions

The objective: **translate business goals into actionable SQL insights**.

---

##  Questions, Approaches & Challenges

### Question 1: High-Value Customers with Multiple Products

**Scenario:**  
The business team wants to identify users who have both **savings** and **investment** plans (cross-selling opportunity).

**Task:**  
Write a query to find customers with at least one **funded savings plan** *and* one **funded investment plan**, sorted by total deposits.

### Approach
- Recognized that the `savings_savingsaccount` table contains all deposit transactions, so an **INNER JOIN** with the `plans_plan` table was used to link transactions to specific plans.
- Created a CTE `funded_plans` to identify all plans with confirmed deposits (`confirmed_amount > 0`), classifying each plan as either savings or investment. The aggregate **SUM** and **GROUP BY** plan (id) column ensures i capture the total deposit per plan (since a plan may have multiple transactions).
- In the `user_summary` CTE, aggregated results per customer was used to count how many savings and investment plans they own and to sum their total deposits across plans.
- Filtered to include only customers with at least one savings and one investment plan.
- Joined the `users_customuser` table only at the final step to retrieve customer names, which helps simplify CTEs and delay potentially expensive joins like string concatenation.
- Sorted the final output by total deposits in descending order.

### Challenge
- A challenge was the complexity of writing the query.
- Used two CTEs to separate concerns clearly and avoid repeating filtering conditions, which improved both readability and maintainability of the query.


---

### Question 2: Transaction Frequency Analysis

**Scenario:**  
The finance team wants to analyze how often customers transact to segment them by behavior (frequent vs. occasional users).

**Task:**  
Calculate the **average number of transactions per month per customer**, then categorize each user as:
- **High Frequency** (≥10/month)
- **Medium Frequency** (3–9/month)
- **Low Frequency** (≤2/month)

### Approach

- Recognized that the `savings_savingsaccount` table contains all transaction data, so it was used as the main source for calculating user activity.
- Created a CTE `monthly_txns` to group transactions by customer and month using `DATE_FORMAT`, then counted the number of transactions each customer made per month.
- Introduced another CTE `avg_txn_per_user` to compute the **average monthly transaction count** for each user. This helps identify consistent patterns across months.
- In the `categorized` CTE, each user was assigned to a frequency category based on their average monthly transaction rate:
  - **High Frequency** for users with ≥10 transactions/month
  - **Medium Frequency** for users with 3–9 transactions/month
  - **Low Frequency** for users with ≤2 transactions/month
- The final query groups the data by category, counting the number of customers per group and calculating the average transactions per month within each group.


### Challenge

- Attempted to simplify the logic by combining the count and average into a single step, but doing so led to inaccurate results due to grouping issues.
- Encountered a `Can't group on 'frequency_category'` error in MySQL when trying to directly group by a derived column.
- Chose a multi-CTE approach to ensure **data was aggregated in the correct order**: first monthly, then per user, then grouped into categories, improving both **accuracy** and **readability**.

---

### Question 3: Account Inactivity Alert

**Scenario:**  
The operations team wants to identify accounts with **no inflow transactions for over one year** (I believe to enable re-engagement campaigns).

**Task:**  
Find all active **savings or investment plans** with **no transactions in the last 365 days**.

### Approach:

- Joined `plans_plan` (which contains all user account plans) with `savings_savingsaccount` (which records deposit transactions).
  
- Focused on **active plans only**, defined as those where either:
  - `is_regular_savings = 1` (savings), or
  - `is_a_fund = 1` (investment).

- Used a CTE (`raw_latest_txn`) to compute the **most recent transaction date** (`MAX(transaction_date)`) for each plan.

- After aggregation, added a **type label** (Savings or Investment) using a `CASE` expression.

- Final filter:
  - Included plans where `last_transaction_date IS NULL` (i.e., **never funded**).
  - Included plans where the most recent transaction was **more than 365 days ago**.

- These two conditions ensure **all plans with no inflow in the last 1 year** are flagged, including **newly created but never-funded plans**.

### Challenge:

- A key interpretation challenge was whether to include plans that were **recently created** but **never funded**. Since the question only specifies *"no transactions in the last 1 year"*, i included these as well — because **zero transactions still means inactivity**, regardless of when the plan was created.

- Carefully delayed the creation of the `type` column until **after aggregation**, to avoid unnecessary computation during the `GROUP BY` step.



---

### Question 4: Customer Lifetime Value (CLV) Estimation

**Scenario:**  
Marketing wants to estimate a **simplified CLV** metric using customer tenure and transaction behavior.

**Task:**  
For each customer, calculate:
- Account tenure (months since account signup)
- Total transactions
- Estimated CLV using:  
  `CLV = (total_transaction_value / tenure_months) * 0.012 * avg_profit_per_transaction`  
  *(Assuming profit_per_transaction = 0.1% of the transaction)*

### Approach

- **Filter for confirmed transactions only**  
   Only transactions with `confirmed_amount > 0` were considered to ensure:
   - Inactive, failed, or unconfirmed deposits don't skew the CLV.
   - Profitability estimates reflect actual cash inflow.
   > Though not explicitly stated in the question, this is standard in financial modeling.

- **CTE `txn_summary`: Per-customer aggregation**  
   - Calculated tenure in months using `TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)`.
   - Counted total transactions per user.
   - Computed **average transaction value in Naira** by dividing by 100 (from kobo).

- **CTE `clv_calc`: Apply simplified CLV formula**  
   - First derived `avg_profit_per_transaction = avg_transaction_value * 0.001`.
   - Then applied the provided CLV formula.
   - Defensive check: used `CASE WHEN tenure > 0` to avoid division-by-zero errors for new users.

-  **Final Output**
   - Ordered by `estimated_clv` descending to show most valuable customers first.


### Challenges & Assumptions

- **Assumption**: Only confirmed transactions are relevant for profit (not explicitly stated).
- **Edge case handling**: Users with zero-month tenure are set to `CLV = 0` to prevent query failure.
- **Model simplification**: CLV is estimated using transaction count and average transaction value — no retention/churn metrics.



---

## Repository Structure

| File              | Description                                |
|-------------------|--------------------------------------------|
| `question1.sql`   | High-Value Customers with Multiple Products |
| `question2.sql`   | Transaction Frequency Analysis |
| `question3.sql`   | Account Inactivity Alert         |
| `question4.sql`   | Customer Lifetime Value (CLV) Estimation   |
| `README.md`       | Customer Lifetime Value (CLV) Estimation          |

---

## Tools Used

- MySQL
- Joins, Aggregates, CTEs, `CASE`, `GROUP BY`
- Clean, modular query structure with performance in mind

---

## Concluson

With this project i was able to think like a business stakeholder, extract value from data, and write reusable queries that are easy to debug and scale.




