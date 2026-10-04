-- ============================================================
-- BANKING ANALYTICS PROJECT
-- DATA QUALITY CHECKS
-- ============================================================
-- Purpose:
-- To validate the completeness, uniqueness, consistency,
-- integrity and basic validity of the banking data before
-- performing business analysis.
--
-- Tables:
-- 1. customer
-- 2. branches
-- 3. account
-- 4. transaction
-- ============================================================
--  To understand Data and Data types 
-- ============================================================

DESC account;
DESC branches;
DESC customer;
DESC transactions;

-- To get each table data type currect and valid 

-- ============================================================
-- 1. TABLE ROW COUNT
-- ============================================================
-- Business Purpose:
-- Verify that all expected tables contain data and understand
-- the approximate size of each dataset.

SELECT 'customer' AS table_name, COUNT(*) AS row_count
FROM customer

UNION ALL

SELECT 'branches' AS table_name, COUNT(*)
FROM branches

UNION ALL

SELECT 'account' table_name, COUNT(*)
FROM account

UNION ALL

SELECT 'transaction' table_name, COUNT(*)
FROM transactions;

customers	10000
accounts	19900
Braches	  200
Transcations	497496

-- ============================================================
-- 2. DUPLICATE CUSTOMER IDs
-- ============================================================
-- customer_id should uniquely identify each customer.

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

--To get not any duplicacy
-- ============================================================
-- 3. DUPLICATE BRANCH IDs
-- ============================================================
-- branch_id should uniquely identify each branch.

SELECT
    branch_id,
    COUNT(*) AS duplicate_count
FROM branches
GROUP BY branch_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. DUPLICATE ACCOUNT IDs
-- ============================================================
-- account_id should uniquely identify each account.

SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM account
GROUP BY account_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. DUPLICATE TRANSACTION IDs
-- ============================================================
-- transaction_id should uniquely identify each transaction.

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. NULL CHECK - CUSTOMER TABLE
-- ============================================================
-- Check important customer fields for missing values.

SELECT
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(first_name IS NULL) AS first_name_nulls,
    SUM(last_name IS NULL) AS last_name_nulls,
    SUM(email IS NULL) AS email_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(state IS NULL) AS state_nulls,
    SUM(date_of_birth IS NULL) AS dob_nulls,
    SUM(customer_segment IS NULL) AS segment_nulls,
    SUM(registration_date IS NULL) AS registration_date_nulls
FROM customer;


-- ============================================================
-- 7. NULL CHECK - BRANCH TABLE
-- ============================================================
-- Check important branch fields for missing values.

SELECT
    SUM(branch_id IS NULL) AS branch_id_nulls,
    SUM(branch_name IS NULL) AS branch_name_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(state IS NULL) AS state_nulls,
    SUM(region IS NULL) AS region_nulls
FROM branches;


-- ============================================================
-- 8. NULL CHECK - ACCOUNT TABLE
-- ============================================================
-- Check important account fields for missing values.

SELECT
    SUM(account_id IS NULL) AS account_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(account_type IS NULL) AS account_type_nulls,
    SUM(account_open_date IS NULL) AS account_open_date_nulls,
    SUM(account_status IS NULL) AS account_status_nulls,
    SUM(balance IS NULL) AS balance_nulls,
    SUM(branch_id IS NULL) AS branch_id_nulls
FROM account;


-- ============================================================
-- 9. NULL CHECK - TRANSACTION TABLE
-- ============================================================
-- Check important transaction fields for missing values.

SELECT
    SUM(transaction_id IS NULL) AS transaction_id_nulls,
    SUM(account_id IS NULL) AS account_id_nulls,
    SUM(transaction_date IS NULL) AS transaction_date_nulls,
    SUM(transaction_type IS NULL) AS transaction_type_nulls,
    SUM(amount IS NULL) AS amount_nulls,
    SUM(payment_method IS NULL) AS payment_method_nulls,
    SUM(merchant IS NULL) AS merchant_nulls,
    SUM(transaction_status IS NULL) AS transaction_status_nulls
FROM transactions;


-- ============================================================
-- 10. ORPHAN ACCOUNTS - CUSTOMER RELATIONSHIP
-- ============================================================
-- Check whether every account belongs to an existing customer.

SELECT
    a.account_id,
    a.customer_id
FROM account a
LEFT JOIN customer c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 11. ORPHAN ACCOUNTS - BRANCH RELATIONSHIP
-- ============================================================
-- Check whether every account is linked to an existing branch.

SELECT
    a.account_id,
    a.branch_id
FROM account a
LEFT JOIN branches b
    ON a.branch_id = b.branch_id
WHERE b.branch_id IS NULL;


-- ============================================================
-- 12. ORPHAN TRANSACTIONS - ACCOUNT RELATIONSHIP
-- ============================================================
-- Check whether every transaction belongs to an existing account.

SELECT
    t.transaction_id,
    t.account_id
FROM transactions t
LEFT JOIN account a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 13. ACCOUNT STATUS DISTRIBUTION
-- ============================================================
-- Identify available account statuses and their frequency.

SELECT
    account_status,
    COUNT(*) AS account_count
FROM account
GROUP BY account_status
ORDER BY account_count DESC;


-- ============================================================
-- 14. TRANSACTION STATUS DISTRIBUTION
-- ============================================================
-- Check Success, Failed and Pending transactions.

SELECT
    transaction_status,
    COUNT(*) AS transaction_count
FROM `transaction`
GROUP BY transaction_status
ORDER BY transaction_count DESC;


-- ============================================================
-- 15. TRANSACTION TYPE DISTRIBUTION
-- ============================================================
-- Check whether transaction types contain expected values.

SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;


-- ============================================================
-- 16. PAYMENT METHOD DISTRIBUTION
-- ============================================================
-- Understand the distribution of transaction payment methods.

SELECT
    payment_method,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_method
ORDER BY transaction_count DESC;


-- ============================================================
-- 17. DATE RANGE CHECK
-- ============================================================
-- Understand the time period covered by each major dataset.

SELECT
    'Customer Registration' AS data_area,
    MIN(registration_date) AS minimum_date,
    MAX(registration_date) AS maximum_date
FROM customer

UNION ALL

SELECT
    'Account Opening',
    MIN(account_open_date),
    MAX(account_open_date)
FROM account

UNION ALL

SELECT
    'Transactions',
    MIN(transaction_date),
    MAX(transaction_date)
FROM `transactions`;


-- ============================================================
-- 18. ACCOUNT OPENED BEFORE CUSTOMER REGISTRATION
-- ============================================================
-- Potential data consistency issue:
-- An account should normally not be opened before the
-- customer's registration date.
--
-- NOTE:
-- Validate the business definition of registration_date
-- before treating these records as errors.

SELECT
    a.account_id,
    a.customer_id,
    a.account_open_date,
    c.registration_date
FROM account a
JOIN customer c
    ON a.customer_id = c.customer_id
WHERE a.account_open_date < c.registration_date;


-- ============================================================
-- 19. TRANSACTION BEFORE ACCOUNT OPENING
-- ============================================================
-- A transaction should normally occur on or after
-- the account opening date.

SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    a.account_open_date
FROM `transaction` t
JOIN account a
    ON t.account_id = a.account_id
WHERE t.transaction_date < a.account_open_date;


-- ============================================================
-- 20. NEGATIVE ACCOUNT BALANCE
-- ============================================================
-- Negative balances may be valid for overdraft-enabled
-- accounts, so these records require business validation.

SELECT
    account_id,
    customer_id,
    account_type,
    balance
FROM account
WHERE balance < 0;


-- ============================================================
-- 21. NEGATIVE TRANSACTION AMOUNT
-- ============================================================
-- Check whether transaction amounts contain negative values.
-- Whether negative values are valid depends on the data
-- recording convention.

SELECT
    transaction_id,
    account_id,
    transaction_type,
    amount
FROM `transaction`
WHERE amount < 0;


-- ============================================================
-- 22. ZERO TRANSACTION AMOUNT
-- ============================================================
-- Zero-value transactions may indicate test, reversal,
-- system-generated or incomplete records.
-- These should be investigated rather than automatically
-- classified as errors.

SELECT
    COUNT(*) AS zero_amount_transactions
FROM `transaction`
WHERE amount = 0;


-- ============================================================
-- END OF DATA QUALITY CHECKS
-- ============================================================
