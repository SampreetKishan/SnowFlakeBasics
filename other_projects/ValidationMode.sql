CREATE OR REPLACE DATABASE OUR_SECOND_DB; 

CREATE OR REPLACE TABLE  OUR_SECOND_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
    );

-- s3://snowflakebucket-copyoption/size/
CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_errors"
url=s3://snowflakebucket-copyoption/size/; 

DESC STAGE manage_db."external_stages"."aws_stage_errors"; 

LIST @manage_db."external_stages"."aws_stage_errors"; 

COPY INTO OUR_SECOND_DB.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_stage_errors"
file_format = (FORMAT_NAME = MANAGE_DB."file_formats"."my_first_file_format")
pattern = ".*Orders.*"
VALIDATION_MODE = "RETURN_5_ROWS"; 

DESC FILE FORMAT MANAGE_DB."file_formats"."my_first_file_format";

select * from our_second_db.public.orders; 


-- let's create another stage which contains with with errors
-- s3://snowflakebucket-copyoption/returnfailed/

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_errors_2"
url =s3://snowflakebucket-copyoption/returnfailed/; 

LIST  @manage_db."external_stages"."aws_stage_errors_2"; 

COPY INTO our_second_db.public.orders
FROM @manage_db."external_stages"."aws_stage_errors_2"
pattern = ".*Details.*"
file_format = (FORMAT_NAME = MANAGE_DB."file_formats"."my_first_file_format")
VALIDATION_MODE="RETURN_ERRORS"; 

COPY INTO our_second_db.public.orders
FROM @manage_db."external_stages"."aws_stage_errors_2"
pattern = ".*Orders.*"
file_format = (FORMAT_NAME = MANAGE_DB."file_formats"."my_first_file_format")
VALIDATION_MODE="RETURN_5_ROWS"; 

select * from our_second_db.public.orders; 

