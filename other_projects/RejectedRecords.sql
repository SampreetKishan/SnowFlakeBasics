-- 's3://snowflakebucket-copyoption/returnfailed/'

CREATE OR REPLACE STAGE manage_db."external_stages"."rejected_records"
url=s3://snowflakebucket-copyoption/returnfailed/;

LIST @manage_db."external_stages"."rejected_records";


select * from our_second_db.public.orders limit 10; 

COPY into our_second_db.public.orders
FROM @manage_db."external_stages"."rejected_records"
file_format=(field_delimiter=',' type=csv skip_header=1)
VALIDATION_MODE = "RETURN_ERRORS";


-------------- Working with error results -----------

CREATE OR REPLACE TABLE  our_second_db.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));


CREATE OR REPLACE TABLE rejected_records AS 
select rejected_record from table(result_scan(last_query_id()));


select * from our_second_db.public.rejected_records; 

---- 2) Saving rejected files without VALIDATION_MODE ---- 

COPY INTO our_first_db.public.orders
FROM  @manage_db."external_stages"."rejected_records"
pattern = ".*Order.*"
file_format =(field_delimiter = ',' type = csv skip_header=1)
ON_ERROR = "CONTINUE"; 

select * from table(validate(orders, job_id => '_last'));

--TRUNCATE TABLE our_first_db.public.orders;

---- 3) Working with rejected records ---- 

select * from rejected_records; 

create or replace table rejected_records_values as 
select 
split_part(rejected_record,',', 1) as ORDER_ID,
split_part(rejected_record,',', 2) as AMOUNT,
split_part(rejected_record,',', 3) as PROFIT,
split_part(rejected_record,',', 4) as QUANTITY,
split_part(rejected_record,',', 5) as CATEGORY,
split_part(rejected_record,',', 6) as SUBCATEGORY,
FROM rejected_records; 

select * from rejected_records_values; 


