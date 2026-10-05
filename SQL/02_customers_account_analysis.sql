-- ============================================================
-- Customer & Account Analysis
-- Database: Banking Analytics
-- Purpose: Understand customer coverage, account ownership,
--          and account distribution across customers.
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
-- and all customer IDs are unique.


-- ============================================================
-- 2. Account and Customer Coverage
-- Business Question:
-- How many accounts exist, and how many unique customers
-- currently have accounts?
-- ============================================================

SELECT
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT account_id) AS total_unique_accounts,
    COUNT(DISTINCT customer_id) AS total_unique_customers
FROM account;

-- Result:
-- Total accounts = 19,900
-- Unique accounts = 19,900
-- Customers with accounts = 8,665
--
-- Insight:
-- There are 19,900 accounts across 8,665 unique customers.
-- Since the number of accounts is higher than the number
-- of customers with accounts, some customers hold multiple accounts.


-- ============================================================
-- 3. Customers Without Accounts
-- Business Question:
-- How many registered customers do not have any account?
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
-- 1,335 registered customers do not have an account.
-- This represents a potential customer activation or
-- account-conversion opportunity.


-- ============================================================
-- 4. Average Accounts per Customer
-- Business Question:
-- On average, how many accounts are held by each
-- customer who has at least one account?
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
-- Customers with accounts hold an average of approximately
-- 2.3 accounts each, indicating that multiple-account
-- ownership is common in the dataset.


-- ============================================================
-- Key Findings
-- ============================================================
--
-- 1. The dataset contains 10,000 unique customers.
-- 2. There are 19,900 unique accounts.
-- 3. 8,665 customers have at least one account.
-- 4. 1,335 customers do not have an account.
-- 5. Account-holding customers have an average of
--    approximately 2.3 accounts each.
--
-- These findings provide the base for further analysis of
-- account types, account status, customer segments,
-- and account balances.
-- ============================================================
