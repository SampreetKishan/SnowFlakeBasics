--  url='s3://snowflakebucket-copyoption/size/';

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_truncatecolumns"
url = 's3://snowflakebucket-copyoption/size/';

LIST @manage_db."external_stages"."aws_stage_truncatecolumns";


CREATE OR REPLACE TABLE  OUR_SECOND_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(10),
    SUBCATEGORY VARCHAR(30));

COPY INTO OUR_SECOND_DB.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_stage_truncatecolumns"
file_format = (type=csv field_delimiter=',' skip_header=1)
pattern = ".*Order.*"
TRUNCATECOLUMNS = TRUE
VALIDATION_MODE="RETURN_ERRORS"; 


COPY INTO OUR_SECOND_DB.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_stage_truncatecolumns"
file_format = (type=csv field_delimiter=',' skip_header=1)
pattern = ".*Order.*"
TRUNCATECOLUMNS = TRUE; 
-- VALIDATION_MODE="RETURN_ERRORS"; 

