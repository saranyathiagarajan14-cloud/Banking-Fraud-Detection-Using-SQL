CREATE DATABASE banking_fraud_db;
USE banking_fraud_db;
	     ----- staging_transactions -----
CREATE TABLE staging_transactions (
    transaction_id VARCHAR(20),
    transaction_amount DECIMAL(12,2),
    login_attempts INT,
    device_risk_score DECIMAL(5,2),
    transfer_frequency INT,
    anomaly_score DECIMAL(8,4),
    account_age_days INT,
    transaction_time_hour INT,
    failed_transactions_last_30d INT,
    avg_monthly_balance DECIMAL(12,2),
    daily_transaction_count INT,
    geo_distance_km DECIMAL(10,2),
    session_duration_minutes DECIMAL(8,2),
    transaction_velocity_score DECIMAL(8,2),
    payment_channel VARCHAR(30),
    authentication_type VARCHAR(30),
    card_present_flag TINYINT,
    international_transaction_flag TINYINT,
    suspicious_ip_flag TINYINT,
    fraud_flag TINYINT
);
DESCRIBE staging_transactions;
SELECT COUNT(*) AS total_records
FROM staging_transactions;
         ----- transactions -----
CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    transaction_amount DECIMAL(12,2),
    transaction_time_hour INT,
    payment_channel VARCHAR(30),
    authentication_type VARCHAR(30),
    card_present_flag TINYINT,
    international_transaction_flag TINYINT,
    fraud_flag TINYINT
);
       ----- accounts -----
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    account_age_days INT,
    avg_monthly_balance DECIMAL(12,2),
    daily_transaction_count INT,
    transfer_frequency INT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
DESCRIBE accounts;
     ----- devices -----
CREATE TABLE devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    device_risk_score DECIMAL(5,2),
    card_present_flag TINYINT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
      ----- login_activity -----
CREATE TABLE login_activity (
    login_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    login_attempts INT,
    failed_transactions_last_30d INT,
    session_duration_minutes DECIMAL(8,2),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
      ----- risk_assessment -----
CREATE TABLE risk_assessment (
    risk_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    anomaly_score DECIMAL(8,4),
    transaction_velocity_score DECIMAL(8,2),
    device_risk_score DECIMAL(5,2),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
     ----- fraud_indicators -----
CREATE TABLE fraud_indicators (
    indicator_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    suspicious_ip_flag TINYINT,
    international_transaction_flag TINYINT,
    geo_distance_km DECIMAL(10,2),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
      ----- payment_channels -----
CREATE TABLE payment_channels (
    channel_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_channel VARCHAR(30) UNIQUE,
    channel_description VARCHAR(100)
);
     ----- authentication_methods -----
CREATE TABLE authentication_methods (
    auth_id INT AUTO_INCREMENT PRIMARY KEY,
    authentication_type VARCHAR(30) UNIQUE,
    auth_description VARCHAR(100)
);
      ----- fraud_cases -----
CREATE TABLE fraud_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    fraud_flag TINYINT,
    anomaly_score DECIMAL(8,4),
    suspicious_ip_flag TINYINT,
    case_status VARCHAR(30),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
      ----- transaction_flags -----
CREATE TABLE transaction_flags (
    flag_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    card_present_flag TINYINT,
    international_transaction_flag TINYINT,
    suspicious_ip_flag TINYINT,
    fraud_flag TINYINT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
INSERT INTO transactions (
    transaction_id,
    transaction_amount,
    transaction_time_hour,
    payment_channel,
    authentication_type,
    card_present_flag,
    international_transaction_flag,
    fraud_flag
)
SELECT
    transaction_id,
    transaction_amount,
    transaction_time_hour,
    payment_channel,
    authentication_type,
    card_present_flag,
    international_transaction_flag,
    fraud_flag
FROM staging_transactions;
SELECT *
FROM transactions;
INSERT INTO accounts (
    transaction_id,
    account_age_days,
    avg_monthly_balance,
    daily_transaction_count,
    transfer_frequency
)
SELECT
    transaction_id,
    account_age_days,
    avg_monthly_balance,
    daily_transaction_count,
    transfer_frequency
FROM staging_transactions;
SELECT * FROM accounts;
INSERT INTO devices (
    transaction_id,
    device_risk_score,
    card_present_flag
)
SELECT
    transaction_id,
    device_risk_score,
    card_present_flag
FROM staging_transactions;
SELECT * FROM devices;
INSERT INTO login_activity (
    transaction_id,
    login_attempts,
    failed_transactions_last_30d,
    session_duration_minutes
)
SELECT
    transaction_id,
    login_attempts,
    failed_transactions_last_30d,
    session_duration_minutes
FROM staging_transactions;
SELECT * FROM login_activity;
INSERT INTO risk_assessment (
    transaction_id,
    anomaly_score,
    transaction_velocity_score,
    device_risk_score
)
SELECT
    transaction_id,
    anomaly_score,
    transaction_velocity_score,
    device_risk_score
FROM staging_transactions;
SELECT * FROM risk_assessment;
INSERT INTO fraud_indicators (
    transaction_id,
    suspicious_ip_flag,
    international_transaction_flag,
    geo_distance_km
)
SELECT
    transaction_id,
    suspicious_ip_flag,
    international_transaction_flag,
    geo_distance_km
FROM staging_transactions;
SELECT * FROM fraud_indicators;
INSERT INTO payment_channels (
    payment_channel,
    channel_description
)
SELECT DISTINCT
    payment_channel,
    CONCAT(payment_channel, ' payment channel')
FROM staging_transactions;
SELECT * FROM payment_channels;
INSERT INTO authentication_methods (
    authentication_type,
    auth_description
)
SELECT DISTINCT
    authentication_type,
    CONCAT(authentication_type, ' authentication')
FROM staging_transactions;
SELECT * FROM authentication_methods;
INSERT INTO fraud_cases (
    transaction_id,
    fraud_flag,
    anomaly_score,
    suspicious_ip_flag,
    case_status
)
SELECT
    transaction_id,
    fraud_flag,
    anomaly_score,
    suspicious_ip_flag,
    CASE
        WHEN fraud_flag = 1 THEN 'Fraud'
        ELSE 'Legitimate'
    END AS case_status
FROM staging_transactions;
SELECT * FROM fraud_cases;
INSERT INTO transaction_flags (
    transaction_id,
    card_present_flag,
    international_transaction_flag,
    suspicious_ip_flag,
    fraud_flag
)
SELECT
    transaction_id,
    card_present_flag,
    international_transaction_flag,
    suspicious_ip_flag,
    fraud_flag
FROM staging_transactions;
SELECT * FROM transaction_flags;

<<<<< ALTER / UPDATE / DELETE >>>>>
1.Add a new column named remarks to the transactions table.
ALTER TABLE transactions
ADD remarks VARCHAR(100);
SELECT * FROM transactions;
2.Update the remarks as Review Required for fraudulent transactions.
UPDATE transactions
SET remarks = 'Review Required'
WHERE fraud_flag = 1;
SELECT * FROM transactions;
3.Update the remarks as International for international transactions.
UPDATE transactions
SET remarks = 'International'
WHERE international_transaction_flag = 1;
SELECT * FROM transactions;


<<<<< SELECT, FILTER & STRING FUNCTIONS >>>>>
1. Display the transactions.
SELECT * FROM transactions;
2. Display all unique payment channels used in the transactions.
SELECT DISTINCT payment_channel
FROM transactions;
3. Display transactions where the payment channel is either UPI, ATM, or POS.
SELECT *
FROM transactions
WHERE payment_channel IN ('UPI', 'ATM', 'POS');
4. Display transactions where the transaction amount is not between 5,000 and 20,000.
SELECT *
FROM transactions
WHERE transaction_amount NOT BETWEEN 5000 AND 20000;
5. Display transactions where the authentication type is NULL.
SELECT *
FROM transactions
WHERE authentication_type IS NULL;
6. Display the authentication type, replacing NULL values with Not Available.
SELECT transaction_id,
       COALESCE(authentication_type, 'Not Available') AS authentication_type
FROM transactions;
7. Combine the transaction ID and payment channel into a single column.
SELECT CONCAT(transaction_id, ' - ', payment_channel) AS transaction_details
FROM transactions;
8. Display transactions where the authentication type is not NULL.
SELECT *
FROM transactions
WHERE authentication_type IS NOT NULL;
9. Display the payment channel in uppercase along with its length.
SELECT payment_channel,
       UPPER(payment_channel) AS uppercase_channel,
       LENGTH(payment_channel) AS channel_length
FROM transactions;
10.Display transactions where the transaction amount is greater than 10,000.
SELECT *
FROM transactions
WHERE transaction_amount > 10000;
11. Display transactions where the transaction amount is less than or equal to 5,000.
SELECT *
FROM transactions
WHERE transaction_amount <= 5000;
12. Display transactions where the amount is greater than 10,000 and the transaction is international.
SELECT *
FROM transactions
WHERE transaction_amount > 10000
AND international_transaction_flag = 1;
13. Display transactions that are either international or fraudulent.
SELECT *
FROM transactions
WHERE international_transaction_flag = 1
OR fraud_flag = 1;
14. Display transactions where the payment channel starts with the letter A.
SELECT *
FROM transactions
WHERE payment_channel LIKE 'A%';
15. Display transactions in descending order of transaction amount.
SELECT *
FROM transactions
ORDER BY transaction_amount DESC;
16. Skip the first 5 transactions and display the next 5 transactions based on transaction amount.
SELECT *
FROM transactions
ORDER BY transaction_amount DESC
LIMIT 5 OFFSET 5;

<<<<< AGGREGATE FUNCTIONS >>>>>
1. Calculate the total transaction amount.
SELECT SUM(transaction_amount) AS total_amount
FROM transactions;
2. Calculate the average transaction amount.
SELECT AVG(transaction_amount) AS average_amount
FROM transactions;
3. Find the highest transaction amount.
SELECT MAX(transaction_amount) AS highest_amount
FROM transactions;
4. Find the lowest transaction amount.
SELECT MIN(transaction_amount) AS lowest_amount
FROM transactions;
5. Count the total number of transactions.
SELECT COUNT(*) AS total_transactions
FROM transactions;

<<<<< GROUP BY & HAVING >>>>>
1.Count the number of transactions for each payment channel.
SELECT payment_channel,
       COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_channel;
2. Find the average transaction amount for each authentication type.
SELECT authentication_type,
       AVG(transaction_amount) AS average_amount
FROM transactions
GROUP BY authentication_type;
3. Display payment channels whose total transaction amount is greater than 50,000.
SELECT payment_channel,
       SUM(transaction_amount) AS total_amount
FROM transactions
GROUP BY payment_channel
HAVING SUM(transaction_amount) > 50000;
4. Find the payment channels having more than 10 transactions and display them in descending order of transaction count.
SELECT payment_channel,
       COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_channel
HAVING COUNT(*) > 10
ORDER BY transaction_count DESC;

<<<<< CONTROL FLOW FUNCTIONS >>>>>
1.Categorize transactions as High if the amount is 10,000 or more, otherwise Low.
SELECT transaction_id,
       transaction_amount,
       IF(transaction_amount >= 10000, 'High', 'Low') AS amount_category
FROM transactions;
2. Categorize transactions as Fraud or Not Fraud based on the fraud flag.
SELECT transaction_id,
       fraud_flag,
       CASE
           WHEN fraud_flag = 1 THEN 'Fraud'
           ELSE 'Not Fraud'
       END AS fraud_status
FROM transactions;

<<<<< WINDOW FUNCTIONS >>>>>
1.Assign a row number to each transaction based on transaction amount in descending order.
SELECT transaction_id,
       transaction_amount,
       ROW_NUMBER() OVER (
           ORDER BY transaction_amount DESC
       ) AS row_num
FROM transactions;
2.Rank transactions based on their transaction amount.
SELECT transaction_id,
       transaction_amount,
       RANK() OVER (
           ORDER BY transaction_amount DESC
       ) AS amount_rank
FROM transactions;
3. Display each transaction along with the running total of transaction amounts.
SELECT transaction_id,
       transaction_amount,
       SUM(transaction_amount) OVER (
           ORDER BY transaction_id
       ) AS running_total
FROM transactions;

<<<<< SUBQUERY >>>>>
1.Display transactions whose amount is greater than the average transaction amount.
SELECT *
FROM transactions
WHERE transaction_amount > (
    SELECT AVG(transaction_amount)
    FROM transactions
);
2. Display the transaction with the highest transaction amount.
SELECT *
FROM transactions
WHERE transaction_amount = (
    SELECT MAX(transaction_amount)
    FROM transactions
);

<<<<< JOIN >>>>>
1.Display the transaction ID, transaction amount, and risk information by joining the transactions and risk_assessment tables using transaction_id.
SELECT t.transaction_id,
       t.transaction_amount,
       r.*
FROM transactions t
INNER JOIN risk_assessment r
ON t.transaction_id = r.transaction_id;
2. Display all transactions along with the matching fraud case details.
SELECT t.transaction_id,
       t.transaction_amount,
       f.*
FROM transactions t
LEFT JOIN fraud_cases f
ON t.transaction_id = f.transaction_id;
3. Display transactions along with their transaction flags where the transaction is marked as fraudulent.
SELECT t.transaction_id,
       t.transaction_amount,
       tf.*
FROM transactions t
INNER JOIN transaction_flags tf
ON t.transaction_id = tf.transaction_id
WHERE t.fraud_flag = 1;


<<<<< WINDOW FUNCTION + CONTROL FLOW >>>>>

1. Rank all transactions by amount and classify them as High Risk if they are fraudulent, otherwise Normal.
SELECT transaction_id,
       transaction_amount,
       fraud_flag,
       RANK() OVER (
           ORDER BY transaction_amount DESC
       ) AS amount_rank,
       CASE
           WHEN fraud_flag = 1 THEN 'High Risk'
           ELSE 'Normal'
       END AS risk_level
FROM transactions;

1. Fraud vs Legitimate count
How many transactions are Fraud and how many are Legitimate?
SELECT
    CASE
        WHEN fraud_flag = 1 THEN 'Fraud'
        ELSE 'Legitimate'
    END AS transaction_status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY fraud_flag;

2. Fraud rate %
What percentage of transactions are fraudulent?
SELECT
    ROUND(
        SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM transactions;

3. Fraud transaction total amount
SELECT
    SUM(transaction_amount) AS total_fraud_amount
FROM transactions
WHERE fraud_flag = 1;

4. Fraud by payment channel
SELECT
    payment_channel,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM transactions
WHERE fraud_flag = 1
GROUP BY payment_channel
ORDER BY fraud_count DESC;

5. Fraud by authentication type
SELECT
    authentication_type,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM transactions
WHERE fraud_flag = 1
GROUP BY authentication_type
ORDER BY fraud_count DESC;

6. International vs Domestic Fraud
SELECT
    CASE
        WHEN international_transaction_flag = 1 THEN 'International'
        ELSE 'Domestic'
    END AS transaction_type,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM transactions
WHERE fraud_flag = 1
GROUP BY international_transaction_flag
ORDER BY fraud_count DESC;

7. Suspicious IP vs Fraud
SELECT
    CASE
        WHEN fi.suspicious_ip_flag = 1 THEN 'Suspicious IP'
        ELSE 'Normal IP'
    END AS ip_status,
    COUNT(*) AS fraud_count,
    SUM(t.transaction_amount) AS fraud_amount
FROM transactions t
INNER JOIN fraud_indicators fi
    ON t.transaction_id = fi.transaction_id
WHERE t.fraud_flag = 1
GROUP BY fi.suspicious_ip_flag
ORDER BY fraud_count DESC;

Device Risk vs Fraud
SELECT
    CASE
        WHEN d.device_risk_score >= 70 THEN 'High Device Risk'
        WHEN d.device_risk_score >= 40 THEN 'Medium Device Risk'
        ELSE 'Low Device Risk'
    END AS device_risk_level,
    COUNT(*) AS fraud_count,
    SUM(t.transaction_amount) AS fraud_amount
FROM transactions t
INNER JOIN devices d
    ON t.transaction_id = d.transaction_id
WHERE t.fraud_flag = 1
GROUP BY
    CASE
        WHEN d.device_risk_score >= 70 THEN 'High Device Risk'
        WHEN d.device_risk_score >= 40 THEN 'Medium Device Risk'
        ELSE 'Low Device Risk'
    END
ORDER BY fraud_count DESC;

Failed Login Activity vs Fraud
SELECT
    CASE
        WHEN la.login_attempts >= 5 THEN 'High Login Attempts'
        WHEN la.login_attempts >= 3 THEN 'Medium Login Attempts'
        ELSE 'Low Login Attempts'
    END AS login_risk_level,
    COUNT(*) AS fraud_count,
    SUM(t.transaction_amount) AS fraud_amount
FROM transactions t
INNER JOIN login_activity la
    ON t.transaction_id = la.transaction_id
WHERE t.fraud_flag = 1
GROUP BY
    CASE
        WHEN la.login_attempts >= 5 THEN 'High Login Attempts'
        WHEN la.login_attempts >= 3 THEN 'Medium Login Attempts'
        ELSE 'Low Login Attempts'
    END
ORDER BY fraud_count DESC;

Fraud by Transaction Time
SELECT
    transaction_time_hour,
    COUNT(*) AS fraud_count,
    SUM(transaction_amount) AS fraud_amount
FROM transactions
WHERE fraud_flag = 1
GROUP BY transaction_time_hour
ORDER BY fraud_count DESC;