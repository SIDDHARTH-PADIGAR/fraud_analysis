-- ============================================================
-- fraud-case-file: queries
-- Dataset: synthetic betting platform, 59K users
-- Each query starts with WHY I ran it, not what it does.
-- ============================================================

-- Q1: Email domain fraud rate
-- WHY: checking if disposable domains are a signal. Expected yes.
-- RESULT: 37% fraud on tempmail/mailnesia vs ~1% on gmail. Confirmed.

SELECT u.email_domain,
       COUNT(fl.user_id) AS fraud_accounts,
       ROUND(100.0 * COUNT(fl.user_id) / COUNT(*), 2) AS fraud_pct
FROM users u
LEFT JOIN fraud_labels fl ON u.user_id = fl.user_id
GROUP BY u.email_domain
ORDER BY fraud_pct DESC;

-- Q2: Payment method decline/chargeback rates
-- WHY: checking if one method is a red flag.
-- RESULT: Flat across all 4 methods (~3.8%). Method is NOT a signal.

SELECT method,
       COUNT(*) AS attempts,
       ROUND(100.0 * SUM(CASE WHEN status = 'declined' THEN 1 ELSE 0 END) / COUNT(*), 2) AS decline_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) / COUNT(*), 2) AS chargeback_rate_pct
FROM deposits
GROUP BY method
ORDER BY decline_rate_pct DESC;

-- Q3: Bonus dollars by fraud status
-- WHY: how much promo money leaks to confirmed fraud?
-- RESULT: 2.9% ($25K of $857K). One-line gate would fix it.

SELECT
    CASE WHEN fl.user_id IS NULL THEN 'not fraud' ELSE 'fraud' END AS segment,
    SUM(pc.bonus_amount) AS bonus_dollars
FROM promo_claims pc
LEFT JOIN fraud_labels fl ON pc.user_id = fl.user_id
GROUP BY 1
ORDER BY bonus_dollars DESC;

-- Q4: Device sharing → fraud rate
-- WHY: checking for multi-account rings. At what count does it become fraud?
-- RESULT: 92% at 5+. Threshold is 3. Deployable block rule.

WITH dev AS (
    SELECT device_id, COUNT(*) AS accounts_on_device
    FROM users GROUP BY device_id
)
SELECT
    CASE WHEN d.accounts_on_device = 1 THEN '1 account'
         WHEN d.accounts_on_device = 2 THEN '2 accounts'
         WHEN d.accounts_on_device BETWEEN 3 AND 4 THEN '3-4 accounts'
         ELSE '5+ accounts' END AS bucket,
    COUNT(*) AS users,
    COUNT(fl.user_id) AS fraud_accounts,
    ROUND(100.0 * COUNT(fl.user_id) / COUNT(*), 1) AS fraud_rate_pct
FROM users u
JOIN dev d ON d.device_id = u.device_id
LEFT JOIN fraud_labels fl ON fl.user_id = u.user_id
GROUP BY 1
ORDER BY 1;

-- Q5: Speed to first deposit → fraud rate
-- WHY: do fraudsters deposit faster? And why is >24h also elevated?
-- RESULT: <1h = 7% fraud (expected). >24h = 2.85% (unexpected, unexplained).

SELECT
    CASE WHEN minutes_to_first_dep <= 60 THEN '1) within 1 hour'
         WHEN minutes_to_first_dep <= 360 THEN '2) 1-6 hours'
         WHEN minutes_to_first_dep <= 1440 THEN '3) 6-24 hours'
         ELSE '4) > 24 hours' END AS bucket,
    COUNT(*) AS depositors,
    COUNT(fl.user_id) AS fraud_accounts,
    ROUND(100.0 * COUNT(fl.user_id) / COUNT(*), 2) AS fraud_rate_pct
FROM (
    SELECT fd.user_id,
           (julianday(fd.first_deposit_ts) - julianday(u.signup_ts)) * 1440 AS minutes_to_first_dep
    FROM (SELECT user_id, MIN(deposit_ts) AS first_deposit_ts
          FROM deposits WHERE status IN ('success','chargeback') GROUP BY user_id) fd
    JOIN users u ON u.user_id = fd.user_id
) f
LEFT JOIN fraud_labels fl ON fl.user_id = f.user_id
GROUP BY 1
ORDER BY 1;   
