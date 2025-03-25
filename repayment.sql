# 1. LOAD REPAYMENT TABLE
#SELECT DATABASE
use credabel;

# 1. LOAD DISBURSMENT TABLE
select * from repayment ;

#RENAME ï»¿date_time COLUMN
alter table repayment
rename column ï»¿date_time tO date_time;

# 2. DATA CLEANING AND PREPROCESSING
# 2.1 CREATE STAGINGB TABLE TO CLEAN DATA
create table repayment_staging
like repayment;

#INSERT DATA 
insert repayment_staging
select * from repayment;


# 2.2 NEW STAGING TABLE FOR DELETING DUPLICATES
CREATE TABLE `repayment_staging2` (
  `date_time` text,
  `customer_id` text,
  `amount` double DEFAULT NULL,
  `rep_month` int DEFAULT NULL,
  `repayment_type` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


#INSERT DATA
insert into repayment_staging2
select *,
row_number() over(
partition by date_time, customer_id, amount, rep_month, repayment_type) as row_num
from repayment_staging;

#SELECT DUPLICATES
select * from repayment_staging2
where row_num > 1;

#DELETE DUPLICATES
delete  from repayment_staging2 where row_num > 1;

#DROP row_num column
alter  table repayment_staging2
drop column row_num ;

#LOAD DATA
select * from repayment_staging2;


# 3. STANDARDIZE DATA
# 3.1 date_time
select date_time from repayment_staging2 limit 10;

#CREATE NEW COLUMN
alter table repayment_staging2 add date_time_converted datetime;

#UPDATE DATA TYPE

#check the data
select date_time
from repayment_staging2
limit 10;

#Update date_time format
update repayment_staging2
set date_time = SUBSTRING_INDEX(date_time, '.', 3);

#update date_time_converted format
update repayment_staging2
set date_time_converted = STR_TO_DATE(date_time, '%d-%b-%y %I.%i.%s %p');

#check updates 
select date_time, date_time_converted
from repayment_staging2
limit 10;

#DROP OLD date_time COLUMN
alter table repayment_staging2  drop column date_time;

#RENAME date_time_converted to date_time
alter table repayment_staging2  rename column date_time_converted  to date_time;

#LOAD TO CHECK CHANGES
select * from repayment_staging2;

#3.2 REP_month
alter table repayment_staging2 add rep_month_date date;

#Update Table
update repayment_staging2
set rep_month_date = str_to_date(concat(left(rep_month, 4), '-', right(rep_month, 2), '-01'), '%Y-%m-%d');

#Check updates
select rep_month,rep_month_date
from repayment_staging2
limit 10;

#DROP OLD rep_month COLUMN
alter table repayment_staging2  drop column rep_month;

#RENAME to rep_month_date to rep_month
alter table repayment_staging2  rename column rep_month_date  to rep_month;

#confirm changes
select * from repayment_staging2;

# 3.3CHECK FOR NULL VALUES
select * from repayment_staging2
where amount IS NULL or date_time IS NULL;

#4. CREATE NEW TABLE
CREATE TABLE `repayments` (
  `customer_id` text,
  `amount` double DEFAULT NULL,
  `repayment_type` text,
  `date_time` datetime DEFAULT NULL,
  `rep_month` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
#INSERT DATA 
insert repayments
select * from repayment_staging2;
select * from repayments limit 20;














