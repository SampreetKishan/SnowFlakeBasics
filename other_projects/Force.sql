-- url='s3://snowflakebucket-copyoption/size/';

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_force"
url='s3://snowflakebucket-copyoption/size/'; 

LIST @manage_db."external_stages"."aws_stage_force"; 

CREATE OR REPLACE TABLE  OUR_SECOND_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

COPY INTO our_second_db.public.orders 
FROM @manage_db."external_stages"."aws_stage_force"
file_format = (type=csv field_delimiter="," skip_header=1)
pattern = ".*Order.*"; 

select count(*) from our_second_db.public.orders; 

-- let's execute the same copy command a second time even though the data source files haven't changed. 
COPY INTO our_second_db.public.orders 
FROM @manage_db."external_stages"."aws_stage_force"
file_format = (type=csv field_delimiter="," skip_header=1)
pattern = ".*Order.*"; 

select count(*) from our_second_db.public.orders; 

-- No new rows/files have been loaded using the copy command for the second time. Because snowflake is smart enough to understand the copying the files a second time will create redundant data

-- However, if one wishes to force a copy of redundant data, they can do so using the "FORCE" option of the copy command

COPY INTO our_second_db.public.orders
FROM @manage_db."external_stages"."aws_stage_force"
file_format = (type = csv field_delimiter=',' skip_header=1)
pattern = ".*Order.*"
FORCE = TRUE; 

select count(*) from our_second_db.public.orders; 