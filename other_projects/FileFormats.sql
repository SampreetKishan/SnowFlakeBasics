select * from our_first_db.public.orders; 

CREATE OR REPLACE TABLE ORDERS_EX (
ORDER_ID VARCHAR(30),
AMOUNT INT,
PROFIT INT,
QUANTITY INT,
CATEGORY VARCHAR(30),
SUBCATEGORY VARCHAR(30)
); 

DROP table orders_ex;

CREATE OR REPLACE SCHEMA MANAGE_DB."file_formats"; 

CREATE OR REPLACE file format manage_db."file_formats"."my_first_file_format"; 

DESC file format MANAGE_DB."file_formats"."my_first_file_format"; 

list @manage_db."external_stages"."aws_stage_on_error"; 
--s3://bucketsnowflakes4/OrderDetails_error.csv

COPY INTO our_first_db.public.orders_ex 
FROM @manage_db."external_stages"."aws_stage_on_error"
file_format = (FORMAT_NAME = manage_db."file_formats"."my_first_file_format")
files = ('OrderDetails_error.csv')
ON_ERROR = "SKIP_FILE_3"; 


TRUNCATE TABLE our_first_db.public.orders_ex; 

ALTER FILE FORMAT manage_db."file_formats"."my_first_file_format"
SET SKIP_HEADER=1; 

DESC FILE FORMAT manage_db."file_formats"."my_first_file_format"; 

COPY into OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @manage_db."external_stages"."aws_stage_on_error"
file_format = (FORMAT_NAME= manage_db."file_formats"."my_first_file_format")
files = ('OrderDetails_error.csv')
ON_ERROR = "CONTINUE"; 







