-- ============================================================
-- Customer & Account Analysis
-- Database: Banking Analytics
-- Purpose:
-- Analyze customer segments, customer age groups, account
-- ownership, account types, account status and balances.
-- ============================================================

USE banking;


-- ============================================================
-- 1. Customer Count Validation
-- Business Question:
-- How many customers are present in the customer table?
-- Are customer IDs unique?
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS total_unique_customers
FROM customer;

-- Result:
-- Total customers = 10,000
-- Unique customers = 10,000
--
-- Insight:
-- The customer table contains 10,000 customer records,
-- with no duplicate customer IDs.


-- ============================================================
-- 2. Account and Customer Coverage
-- Business Question:
-- How many accounts exist and how many unique customers
-- have at least one account?
-- ============================================================

SELECT
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT account_id) AS total_unique_accounts,
    COUNT(DISTINCT customer_id) AS customers_with_accounts
FROM account;

-- Result:
-- Total accounts = 19,900
-- Unique accounts = 19,900
-- Customers with accounts = 8,665
--
-- Insight:
-- 19,900 accounts are associated with 8,665 unique customers.
-- This indicates that some customers hold multiple accounts.


-- ============================================================
-- 3. Customers Without Accounts
-- Business Question:
-- How many registered customers do not have an account?
-- ============================================================

SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT a.customer_id) AS customers_with_accounts,
    COUNT(DISTINCT c.customer_id)
        - COUNT(DISTINCT a.customer_id) AS customers_without_accounts
FROM customer c
LEFT JOIN account a
    ON c.customer_id = a.customer_id;

-- Result:
-- Total customers = 10,000
-- Customers with accounts = 8,665
-- Customers without accounts = 1,335
--
-- Insight:
-- 1,335 customers in the customer master do not have an
-- associated account record. This can be investigated as
-- a potential customer activation or conversion opportunity.


-- ============================================================
-- 4. Average Accounts per Customer
-- Business Question:
-- How many accounts are held on average by customers
-- who have at least one account?
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT account_id) AS unique_accounts,
    ROUND(
        COUNT(DISTINCT account_id) /
        COUNT(DISTINCT customer_id),
        3
    ) AS avg_accounts_per_customer
FROM account;

-- Result:
-- Customers with accounts = 8,665
-- Unique accounts = 19,900
-- Average accounts per customer = 2.297
--
-- Insight:
-- Customers with accounts hold approximately 2.3 accounts
-- on average, indicating multi-account ownership in the dataset.


-- ============================================================
-- 5. Customer Segment Analysis
-- Business Question:
-- How are customers distributed across customer segments?
-- ============================================================

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customer),
        2
    ) AS customer_contribution_percentage
FROM customer
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Result:
-- Standard = 3,376 customers (33.76%)
-- Premium  = 3,341 customers (33.41%)
-- Business = 3,283 customers (32.83%)
--
-- Insight:
-- Customer distribution is relatively balanced across the
-- three segments. Standard has the highest customer count,
-- followed closely by Premium and Business.


-- ============================================================
-- 6. Customer Age Group Analysis
-- Business Question:
-- What is the approximate age-group distribution of customers?
-- ============================================================

WITH customer_age AS
(
    SELECT
        customer_id,
        2026 - YEAR(date_of_birth) AS age_in_years
    FROM customer
),

age_break AS
(
    SELECT
        customer_id,
        age_in_years,
        CASE
            WHEN age_in_years <= 25 THEN 'Youth (0-25)'
            WHEN age_in_years <= 45 THEN 'Young (26-45)'
            WHEN age_in_years <= 60 THEN 'Old (46-60)'
            ELSE 'Very Old (61+)'
        END AS age_group
    FROM customer_age
)

SELECT
    age_group,
    COUNT(customer_id) AS total_customers,
    ROUND(
        COUNT(customer_id) * 100.0 /
        (SELECT COUNT(*) FROM customer),
        2
    ) AS customer_percentage
FROM age_break
GROUP BY age_group
ORDER BY total_customers DESC;

-- Result:
-- Very Old (61+) = 3,232 customers (32.32%)
-- Young (26-45)  = 3,134 customers (31.34%)
-- Old (46-60)    = 2,455 customers (24.55%)
-- Youth (0-25)   = 1,179 customers (11.79%)
--
-- Insight:
-- The 61+ age group represents the largest customer group,
-- followed closely by customers aged 26-45.
-- Customers aged 0-25 represent the smallest group.
--
-- Note:
-- Age is calculated using the year 2026 and YEAR(date_of_birth),
-- so this is an approximate age grouping.


-- ============================================================
-- 7. Overall Account Balance Analysis
-- Business Question:
-- What is the overall balance position across accounts?
-- ============================================================

SELECT
    ROUND(SUM(balance), 2) AS total_account_balance,
    ROUND(MAX(balance), 2) AS max_account_balance,
    ROUND(MIN(balance), 2) AS min_account_balance,
    ROUND(
        SUM(balance) / COUNT(DISTINCT account_id),
        2
    ) AS avg_account_balance,
    ROUND(
        SUM(balance) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_balance_per_customer
FROM account;

-- Result:
-- Total account balance = 4,991,145,230.41
-- Maximum account balance = 499,977.56
-- Minimum account balance = 529.45
-- Average account balance = 250,811.32
-- Average balance per customer = 576,012.14
--
-- Insight:
-- The dataset contains approximately 4.99 billion in total
-- account balances.
-- The average account balance is approximately 250.8K.
-- The average balance per account-holding customer is
-- approximately 576.0K.
--
-- The difference between account-level and customer-level
-- averages is influenced by customers holding multiple accounts.


-- ============================================================
-- 8. Account Type Analysis
-- Business Question:
-- How are accounts and balances distributed across
-- different account types?
-- ============================================================

WITH account_type_analysis AS
(
    SELECT
        account_type,
        COUNT(*) AS total_accounts,
        COUNT(DISTINCT customer_id) AS total_customers,
        ROUND(SUM(balance), 2) AS total_balance
    FROM account
    GROUP BY account_type
)

SELECT
    account_type,
    total_accounts,
    total_customers,
    total_balance,
    ROUND(
        total_balance / total_accounts,
        2
    ) AS avg_account_balance
FROM account_type_analysis
ORDER BY total_accounts DESC;

-- Result:
-- Salary:
--   Accounts = 6,721
--   Customers = 4,866
--   Total balance = 1,675,917,280.02
--   Average account balance = 249,355.35
--
-- Savings:
--   Accounts = 6,649
--   Customers = 4,892
--   Total balance = 1,667,972,628.54
--   Average account balance = 250,860.68
--
-- Current:
--   Accounts = 6,530
--   Customers = 4,857
--   Total balance = 1,647,255,321.85
--   Average account balance = 252,259.62
--
-- Insight:
-- Account volumes are relatively balanced across Salary,
-- Savings and Current accounts.
--
-- Current accounts have the highest average account balance,
-- while Salary accounts have the highest total balance because
-- they have the largest number of accounts.


-- ============================================================
-- 9. Account Status Analysis
-- Business Question:
-- What proportion of accounts are Active, Dormant or Closed?
-- How much balance is associated with each status?
-- ============================================================

SELECT
    account_status,
    COUNT(*) AS total_accounts,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM account),
        2
    ) AS account_percentage,
    ROUND(SUM(balance), 2) AS total_balance
FROM account
GROUP BY account_status
ORDER BY total_accounts DESC;

-- Result:
-- Active:
--   Accounts = 11,856
--   Share = 59.58%
--   Total balance = 2,967,491,142.72
--
-- Dormant:
--   Accounts = 4,023
--   Share = 20.22%
--   Total balance = 1,007,613,804.78
--
-- Closed:
--   Accounts = 4,021
--   Share = 20.21%
--   Total balance = 1,016,040,282.91
--
-- Insight:
-- Active accounts represent 59.58% of all accounts.
-- Dormant and Closed accounts together represent approximately
-- 40.43% of the account base.
--
-- The balance associated with Dormant and Closed accounts
-- makes account-status analysis important for understanding
-- account engagement and potential reactivation opportunities.


-- ============================================================
-- KEY CUSTOMER & ACCOUNT FINDINGS
-- ============================================================
--
-- 1. 10,000 unique customers are present in the dataset.
--
-- 2. 19,900 unique accounts are associated with 8,665
--    customers.
--
-- 3. 1,335 customers do not have an associated account.
--
-- 4. Account-holding customers have an average of
--    approximately 2.3 accounts.
--
-- 5. Customer segments are relatively balanced:
--    Standard = 33.76%
--    Premium  = 33.41%
--    Business = 32.83%
--
-- 6. The 61+ age group is the largest customer group
--    at 32.32%, while the 0-25 group is the smallest
--    at 11.79%.
--
-- 7. Total account balance is approximately 4.99 billion,
--    with an average account balance of approximately 250.8K.
--
-- 8. Salary accounts have the highest account volume
--    at 6,721 accounts.
--
-- 9. Current accounts have the highest average balance
--    at approximately 252.3K per account.
--
-- 10. Active accounts represent 59.58% of all accounts.
--     Dormant and Closed accounts together represent
--     approximately 40.43% of the account base.
--
-- 11. Dormant and Closed accounts together hold more than
--     2.02 billion in account balances, making account
--     reactivation and retention a potential area for
--     further business analysis.
--
-- ============================================================
-- NEXT ANALYSIS:
-- Transaction Analysis will be handled separately.
-- Planned areas include transaction volume, transaction
-- value, payment methods, failed transactions, risk patterns,
-- monthly trends and customer transaction behavior.
-- ============================================================
