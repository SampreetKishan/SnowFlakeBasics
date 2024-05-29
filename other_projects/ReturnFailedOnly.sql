-- 's3://snowflakebucket-copyoption/returnfailed/';

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_returnfailed"
url=s3://snowflakebucket-copyoption/returnfailed/; 


CREATE OR REPLACE TABLE  OUR_SECOND_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

LIST @manage_db."external_stages"."aws_stage_returnfailed";

COPY INTO OUR_SECOND_DB.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_stage_returnfailed"
pattern = ".*Order.*"
file_format = (type = csv field_delimiter=',' skip_header=1)
ON_ERROR = "CONTINUE"
RETURN_FAILED_ONLY=TRUE;


