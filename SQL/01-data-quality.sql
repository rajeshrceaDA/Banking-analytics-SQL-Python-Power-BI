USE banking;

-- ============================================================
-- BANKING ANALYTICS PROJECT
-- File: Data Quality.sql
-- Purpose:
-- Validate data integrity, completeness, consistency and
-- basic business-rule exceptions across the banking database.
--
-- Tables:
-- 1. customer       - Customer master data
-- 2. account        - Customer account information
-- 3. branches       - Branch master data
-- 4. transactions   - Transaction-level data
-- ============================================================


-- ============================================================
-- 1. TABLE STRUCTURE CHECK
-- Business Question:
-- What fields are available in each banking table?
-- ============================================================

DESC customer;
DESC account;
DESC branches;
DESC transactions;


-- ============================================================
-- 2. TABLE ROW COUNT
-- Business Question:
-- How much data is available in each table?
-- ============================================================

SELECT 'customer' AS table_name, COUNT(*) AS total_rows
FROM customer

UNION ALL

SELECT 'account' AS table_name, COUNT(*) AS total_rows
FROM account

UNION ALL

SELECT 'branches' AS table_name, COUNT(*) AS total_rows
FROM branches

UNION ALL

SELECT 'transactions' AS table_name, COUNT(*) AS total_rows
FROM transactions;


-- Expected dataset size:
-- Customer      : 10,000
-- Account       : 19,900
-- Branches      : 200
-- Transactions  : 497,496
-- Total         : 527,596


-- ============================================================
-- 3. DUPLICATE CUSTOMER ID CHECK
-- Business Question:
-- Are customer IDs unique?
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Result:
-- No duplicate customer IDs identified.


-- ============================================================
-- 4. DUPLICATE BRANCH ID CHECK
-- Business Question:
-- Are branch IDs unique?
-- ============================================================

SELECT
    branch_id,
    COUNT(*) AS duplicate_count
FROM branches
GROUP BY branch_id
HAVING COUNT(*) > 1;


-- Result:
-- No duplicate branch IDs identified.


-- ============================================================
-- 5. DUPLICATE ACCOUNT ID CHECK
-- Business Question:
-- Are account IDs unique?
-- ============================================================

SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM account
GROUP BY account_id
HAVING COUNT(*) > 1;


-- Result:
-- No duplicate account IDs identified.


-- ============================================================
-- 6. DUPLICATE TRANSACTION ID CHECK
-- Business Question:
-- Are transaction IDs unique?
-- ============================================================

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- Result:
-- No duplicate transaction IDs identified.


-- ============================================================
-- 7. NULL CHECK - CUSTOMER
-- Business Question:
-- Are important customer fields missing?
-- ============================================================

SELECT
    COUNT(*) AS total_customers,

    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(first_name IS NULL) AS null_first_name,
    SUM(last_name IS NULL) AS null_last_name,
    SUM(email IS NULL) AS null_email,
    SUM(city IS NULL) AS null_city,
    SUM(state IS NULL) AS null_state,
    SUM(date_of_birth IS NULL) AS null_date_of_birth,
    SUM(customer_segment IS NULL) AS null_customer_segment,
    SUM(registration_date IS NULL) AS null_registration_date

FROM customer;


-- Actual finding:
-- 50 customer records have NULL email values.
-- Other checked customer fields have 0 NULL values.


-- ============================================================
-- 8. NULL CHECK - BRANCH
-- Business Question:
-- Are important branch fields missing?
-- ============================================================

SELECT
    COUNT(*) AS total_branches,

    SUM(branch_id IS NULL) AS null_branch_id,
    SUM(branch_name IS NULL) AS null_branch_name,
    SUM(city IS NULL) AS null_city,
    SUM(state IS NULL) AS null_state,
    SUM(region IS NULL) AS null_region

FROM branches;


-- Actual finding:
-- No NULL values identified in the checked branch fields.


-- ============================================================
-- 9. NULL CHECK - ACCOUNT
-- Business Question:
-- Are important account fields missing?
-- ============================================================

SELECT
    COUNT(*) AS total_accounts,

    SUM(account_id IS NULL) AS null_account_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(account_type IS NULL) AS null_account_type,
    SUM(account_open_date IS NULL) AS null_account_open_date,
    SUM(account_status IS NULL) AS null_account_status,
    SUM(balance IS NULL) AS null_balance,
    SUM(branch_id IS NULL) AS null_branch_id

FROM account;


-- Actual finding:
-- No NULL values identified in the checked account fields.


-- ============================================================
-- 10. NULL CHECK - TRANSACTIONS
-- Business Question:
-- Are important transaction fields missing?
-- ============================================================

SELECT
    COUNT(*) AS total_transactions,

    SUM(transaction_id IS NULL) AS null_transaction_id,
    SUM(account_id IS NULL) AS null_account_id,
    SUM(transaction_date IS NULL) AS null_transaction_date,
    SUM(transaction_type IS NULL) AS null_transaction_type,
    SUM(amount IS NULL) AS null_amount,
    SUM(payment_method IS NULL) AS null_payment_method,
    SUM(merchant IS NULL) AS null_merchant,
    SUM(transaction_status IS NULL) AS null_transaction_status

FROM transactions;


-- Actual finding:
-- 2,484 transaction records have NULL merchant values.
-- Other checked transaction fields have 0 NULL values.
--
-- Note:
-- NULL merchant values are treated as a data-quality finding.
-- Business validity should be investigated by transaction type
-- and payment method before treating them as errors.


-- ============================================================
-- 11. ORPHAN ACCOUNT - CUSTOMER RELATIONSHIP
-- Business Question:
-- Are there accounts linked to non-existing customers?
-- ============================================================

SELECT
    COUNT(*) AS orphan_accounts
FROM account a
LEFT JOIN customer c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Actual result:
-- 0 orphan accounts.


-- ============================================================
-- 12. ORPHAN ACCOUNT - BRANCH RELATIONSHIP
-- Business Question:
-- Are there accounts linked to non-existing branches?
-- ============================================================

SELECT
    COUNT(*) AS orphan_accounts
FROM account a
LEFT JOIN branches b
    ON a.branch_id = b.branch_id
WHERE b.branch_id IS NULL;


-- Actual result:
-- 0 orphan accounts.


-- ============================================================
-- 13. ORPHAN TRANSACTION - ACCOUNT RELATIONSHIP
-- Business Question:
-- Are transactions linked to non-existing accounts?
-- ============================================================

SELECT
    COUNT(*) AS orphan_transactions
FROM transactions t
LEFT JOIN account a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- Actual result:
-- 0 orphan transactions.


-- ============================================================
-- 14. ACCOUNT STATUS DISTRIBUTION
-- Business Question:
-- What is the distribution of account statuses?
-- ============================================================

SELECT
    account_status,
    COUNT(*) AS total_accounts,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM account),
        2
    ) AS account_percentage,
    ROUND(SUM(balance), 2) AS total_balance
FROM account
GROUP BY account_status
ORDER BY total_accounts DESC;


-- Actual result:
--
-- Active   : 11,856 | 59.58%
-- Dormant  : 4,023  | 20.22%
-- Closed   : 4,021  | 20.21%


-- ============================================================
-- 15. TRANSACTION STATUS DISTRIBUTION
-- Business Question:
-- What proportion of transactions are successful, pending
-- or failed?
-- ============================================================

SELECT
    transaction_status,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS transaction_percentage
FROM transactions
GROUP BY transaction_status
ORDER BY total_transactions DESC;


-- Actual result:
--
-- Success  : 298,352 | 59.97%
-- Pending  : 99,537  | 20.01%
-- Failed   : 99,508  | 20.00%
-- UNKNOWN  : 99      | 0.02%
--
-- Insight:
-- Approximately 60% of transactions were successful.
-- Pending and failed transactions each represent approximately
-- 20% of total transactions.
-- UNKNOWN status is a data-quality exception requiring review.


-- ============================================================
-- 16. TRANSACTION TYPE DISTRIBUTION
-- Business Question:
-- How are transactions distributed between Credit and Debit?
-- ============================================================

SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS transaction_percentage
FROM transactions
GROUP BY transaction_type
ORDER BY total_transactions DESC;


-- Actual result:
--
-- Credit : 248,939 | 50.04%
-- Debit  : 248,557 | 49.96%
--
-- Insight:
-- Credit and Debit transactions are almost evenly distributed,
-- indicating a balanced transaction mix in the dataset.


-- ============================================================
-- 17. PAYMENT METHOD DISTRIBUTION
-- Business Question:
-- Which payment methods are most frequently used?
-- ============================================================

SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS transaction_percentage
FROM transactions
GROUP BY payment_method
ORDER BY total_transactions DESC;


-- Actual result:
--
-- IMPS : 83,447
-- ATM  : 83,130
-- UPI  : 82,934
-- NEFT : 82,763
-- RTGS : 82,684
-- POS  : 82,538
--
-- Insight:
-- Transaction volume is relatively evenly distributed across
-- all six payment methods.
-- IMPS has the highest transaction count, while POS has the lowest.
-- No single payment method dominates the dataset.


-- ============================================================
-- 18. DATE RANGE CHECK
-- Business Question:
-- What is the available data period across customers,
-- accounts and transactions?
-- ============================================================

SELECT
    'Customer Registration' AS data_entity,
    MIN(registration_date) AS start_date,
    MAX(registration_date) AS end_date
FROM customer

UNION ALL

SELECT
    'Account Opening' AS data_entity,
    MIN(account_open_date) AS start_date,
    MAX(account_open_date) AS end_date
FROM account

UNION ALL

SELECT
    'Transactions' AS data_entity,
    MIN(transaction_date) AS start_date,
    MAX(transaction_date) AS end_date
FROM transactions;


-- Actual result:
--
-- Customer Registration : 2021-08-07 to 2026-08-07
-- Account Opening       : 2021-08-07 to 2026-08-07
-- Transactions          : 2025-08-07 to 2026-08-07
--
-- Insight:
-- Customer and account data cover approximately five years,
-- while transaction data covers approximately one year.
-- Transaction trend analysis should therefore be interpreted
-- within the available transaction period.


-- ============================================================
-- 19. ACCOUNT OPENED BEFORE CUSTOMER REGISTRATION
-- Business Question:
-- Are there accounts where the account opening date is earlier
-- than the customer's registration date?
--
-- Business Rule:
-- account_open_date should normally be >= registration_date.
-- ============================================================

SELECT
    COUNT(*) AS invalid_account_records
FROM account a
JOIN customer c
    ON a.customer_id = c.customer_id
WHERE a.account_open_date < c.registration_date;


-- Actual result:
-- 10,103 records
--
-- Insight:
-- 10,103 account records have an account opening date earlier
-- than the corresponding customer registration date.
--
-- This is a potential data-quality/business-rule exception.
-- Possible reasons may include historical data migration or
-- differences in how registration and account-opening dates
-- are defined in the source system.
-- Further investigation is recommended before treating all
-- records as invalid.


-- ============================================================
-- 20. TRANSACTION BEFORE ACCOUNT OPENING
-- Business Question:
-- Are there transactions recorded before the related account
-- was opened?
--
-- Business Rule:
-- transaction_date should normally be >= account_open_date.
-- ============================================================

SELECT
    COUNT(*) AS invalid_transaction_records
FROM transactions t
JOIN account a
    ON t.account_id = a.account_id
WHERE t.transaction_date < a.account_open_date;


-- Result should be reviewed from the query output.
-- Do not classify the records as invalid without investigating
-- the source-system date definitions.


-- ============================================================
-- 21. NEGATIVE ACCOUNT BALANCE
-- Business Question:
-- Are there accounts with a negative balance?
-- ============================================================

SELECT
    COUNT(*) AS negative_balance_accounts,
    ROUND(SUM(balance), 2) AS total_negative_balance
FROM account
WHERE balance < 0;


-- Negative balances may be valid in some banking products.
-- Therefore, this should be treated as a validation check,
-- not automatically as an error.


-- ============================================================
-- 22. NEGATIVE TRANSACTION AMOUNT
-- Business Question:
-- Are transaction amounts stored as negative values?
-- ============================================================

SELECT
    COUNT(*) AS negative_amount_transactions,
    ROUND(SUM(amount), 2) AS total_negative_amount
FROM transactions
WHERE amount < 0;


-- Negative amounts may indicate a specific transaction
-- representation depending on the source-system design.
-- Investigate transaction_type before classifying them as errors.


-- ============================================================
-- 23. ZERO TRANSACTION AMOUNT
-- Business Question:
-- Are there transactions with zero monetary value?
-- ============================================================

SELECT
    COUNT(*) AS zero_amount_transactions
FROM transactions
WHERE amount = 0;


-- Zero-value transactions may represent test, reversal,
-- validation or system-generated records.
-- Further investigation is required before classification.


-- ============================================================
-- DATA QUALITY SUMMARY
-- ============================================================

/*
DATASET SIZE
--------------------------------------------------------------
Customer Records       : 10,000
Account Records        : 19,900
Branch Records         : 200
Transaction Records    : 497,496
Total Records          : 527,596


KEY DATA QUALITY FINDINGS
--------------------------------------------------------------
1. Duplicate customer IDs       : 0
2. Duplicate account IDs        : 0
3. Duplicate branch IDs         : 0
4. Duplicate transaction IDs    : 0

5. Customer email NULLs          : 50
6. Transaction merchant NULLs    : 2,484

7. Orphan accounts - customer    : 0
8. Orphan accounts - branch      : 0
9. Orphan transactions - account : 0

10. UNKNOWN transaction status   : 99

11. Account opened before
    customer registration        : 10,103 records


KEY OBSERVATIONS
--------------------------------------------------------------
- Primary identifiers are unique across the checked tables.
- Referential integrity checks returned no orphan records.
- Missing customer emails represent a small data-completeness
  issue.
- Missing merchant values are present in 2,484 transactions
  and require business-context investigation.
- Approximately 60% of transactions are successful.
- Pending and failed transactions each account for
  approximately 20% of transactions.
- Credit and Debit transaction volumes are almost equal.
- Payment methods have relatively balanced transaction volumes.
- Customer/account data covers approximately five years,
  while transaction data covers approximately one year.
- 10,103 account records violate the expected chronological
  relationship between customer registration and account opening.

NEXT ANALYSIS
--------------------------------------------------------------
Transaction-level performance, failed transaction analysis,
risk patterns and business insights are covered separately
in:

    Transaction Analysis.sql
    Failed and Risk Analysis.sql
    Business Analysis and Insight.sql
*/
