# 2. DATA ANALYSIS
#2.1 LOAN_AMOUNT / TENURE RATIO
USE credabel;

-- Loan Amount and Fee Summary by Tenure
SELECT 
    tenure,
    COUNT(DISTINCT customer_id) AS num_loans,
   ROUND( AVG(loan_amount),2) AS avg_loan_amount,
   ROUND( AVG(loan_fee) ,2) AS avg_loan_fee,
   ROUND( AVG(loan_fee/loan_amount), 2 )AS fee_to_loan_ratio
FROM disbursments
GROUP BY tenure;
#RESULT : highest fee to loan ratio has 30 day tenure,lowest fee to loan ratio has 7 day tenure
#RESULT : highest loans have tenure of 14 days,then 7 days then 30 days

#TENURE 
#count
SELECT tenure,count(tenure) AS num_tenures
FROM disbursments
GROUP BY tenure;
#RESULT 14 DAYS TENURES ARE MORE THEN,7 DAYS THEN 30 DAYS

#sum
SELECT tenure,sum(tenure) AS total_tenures
FROM disbursments
GROUP BY tenure 
ORDER BY tenure ASC;
#RESULT total_tenure given 14 days,30 days,7 days

#LOAN_AMOUNT TO FEE RATIO
SELECT 
    loan_amount,
    AVG(loan_amount) AS avg_loan_amount,
    AVG(loan_fee) AS avg_loan_fee,
    AVG(loan_fee/loan_amount) AS fee_to_loan_ratio
FROM disbursments
GROUP BY loan_amount;

#2.3 REPAYMENT PATTERN SUMMARY
-- Repayment Summaries by Customer and Repayment Type
SELECT 
    rp.customer_id,
    SUM(CASE WHEN rp.repayment_type = 'Automatic' THEN rp.amount ELSE 0 END) AS total_automatic_repayments,
    SUM(CASE WHEN rp.repayment_type = 'Manual' THEN rp.amount ELSE 0 END) AS total_manual_repayments,
    COUNT(*) AS total_repayment_events
FROM repayments AS rp
GROUP BY rp.customer_id;
use credabel;

#repayment_type
SELECT repayment_type,
    SUM(CASE WHEN repayment_type = 'Automatic' THEN 1  END) AS total_automatic_repayments,
    SUM(CASE WHEN repayment_type = 'Manual' THEN 2 END) AS total_manual_repayments
FROM repayments
GROUP BY repayment_type;  
#RESULT manual repayment most popular compared to automatic

#repayment type distribution
SELECT repayment_type,
SUM(amount) AS total_repayment_amount,
(SUM(amount)* 100.0 /(SELECT SUM(amount) FROM repayments)) AS percentage
FROM repayments
GROUP BY repayment_type; 
#RESULT : Manual have 57.57 % ,Automatic 42.43%r


