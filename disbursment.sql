#SELECT DATABASE
use credabel;

# 1. LOAD DISBURSMENT TABLE
select * from disbursment ;

#RENAME ï»¿customer_id COLUMN
alter table disbursment
rename column ï»¿customer_id to customer_id;

# 2. DATA CLEANING AND PREPROCESSING
# 2.1 CREATE STAGINGB TABLE TO CLEAN DATA
create table disbursment_staging
like disbursment;

#INSERT DATA 
insert disbursment_staging
select * from disbursment;


# 2.2 NEW STAGING TABLE FOR DELETING DUPLICATES
CREATE TABLE `disbursment_staging2` (
  `customer_id` text,
  `disb_date` text,
  `tenure` text,
  `account_num` text,
  `loan_amount` int DEFAULT NULL,
  `loan_fee` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#INSERT DATA
insert into disbursment_staging2
select *,
row_number() over(
partition by customer_id, disb_date, tenure, account_num, loan_amount, loan_fee) as row_num
from disbursment_staging;

#SELECT DUPLICATES
select * from disbursment_staging2
where row_num > 1;

#DELETE DUPLICATES
delete  from disbursment_staging2 where row_num > 1;

#DROP row_num column
alter  table disbursment_staging2
drop column row_num ;

#LOAD DATA
select * from disbursment_staging2 limit 10;


# 3. STANDARDIZE DATA
# 3.1 disb_date
select disb_date from disbursment_staging2 limit 10;

#CREATE NEW COLUMN
alter table disbursment_staging2 add disb_date_converted date;

#UPDATE DATA TYPE
update disbursment_staging2
set disb_date_converted = STR_TO_DATE(disb_date, '%d-%b-%y');

#CHECK UPDATES
select disb_date, disb_date_converted
from disbursment_staging2
limit 10;

#DROP OLD disb_date COLUMN
alter table disbursment_staging2  drop column disb_date;

#RENAME disb_date_converted to disb_date
alter table disbursment_staging2  rename column disb_date_converted  to disb_date;

#LOAD TO CHECK CHANGES
select * from disbursment_staging2;

# 3.2 CHECK FOR NULL VALUES
select * from disbursment_staging2
where loan_amount IS NULL or disb_date IS NULL;

#4. CREATE NEW TABLE
CREATE TABLE `disbursments` (
  `customer_id` text,
  `tenure` text,
  `account_num` text,
  `loan_amount` int DEFAULT NULL,
  `loan_fee` double DEFAULT NULL,
  `disb_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#INSERT DATA 
insert disbursments
select * from disbursment_staging2;
select * from disbursments limit 20;












