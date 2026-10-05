-- ============================================================
-- Customer & Account Analysis
-- Database: Banking Analytics
-- Purpose:
-- Analyze customer segments, age groups, account ownership,
-- and account balance distribution.
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
-- associated account record. This can be investigated further
-- as a potential customer activation or conversion opportunity.


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
--
-- This balanced distribution allows further comparison of
-- account ownership, balances, and transaction behavior
-- across segments.


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
-- The 61+ age group represents the largest customer segment
-- in the dataset, followed closely by customers aged 26-45.
-- Customers aged 0-25 represent the smallest group.
--
-- Note:
-- Age is calculated using the year 2026 and YEAR(date_of_birth).
-- This provides an approximate age grouping rather than an
-- exact age based on the customer's birth date.


-- ============================================================
-- 7. Customer Account Balance Analysis
-- Business Question:
-- What is the overall account balance position and average
-- balance across accounts and account-holding customers?
-- ============================================================

SELECT
    ROUND(SUM(balance), 2) AS total_account_balance,
    ROUND(MAX(balance), 2) AS max_account_balance,
    ROUND(MIN(balance), 2) AS min_account_balance,
    ROUND(
        SUM(balance) /
        COUNT(DISTINCT account_id),
        2
    ) AS avg_account_balance,
    ROUND(
        SUM(balance) /
        COUNT(DISTINCT customer_id),
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
--
-- The average account balance is approximately 250.8K,
-- while the average balance per account-holding customer
-- is approximately 576.0K.
--
-- The difference between these two averages is driven by
-- customers holding multiple accounts.


-- ============================================================
-- KEY CUSTOMER & ACCOUNT FINDINGS
-- ============================================================
--
-- 1. The dataset contains 10,000 unique customers.
--
-- 2. There are 19,900 unique accounts associated with
--    8,665 customers.
--
-- 3. 1,335 customers do not have an associated account.
--
-- 4. Account-holding customers have an average of
--    approximately 2.3 accounts each.
--
-- 5. Customer segments are relatively balanced:
--    Standard 33.76%, Premium 33.41%, Business 32.83%.
--
-- 6. The 61+ age group is the largest customer age group
--    at 32.32%, while the 0-25 group is the smallest
--    at 11.79%.
--
-- 7. Total account balance is approximately 4.99 billion,
--    with an average account balance of approximately 250.8K.
--
-- ============================================================
-- Next Analysis:
-- Account type, account status, transaction activity,
-- failed transactions, risk indicators, and business insights.
-- ============================================================
