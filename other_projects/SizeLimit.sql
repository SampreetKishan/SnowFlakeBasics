-- url='s3://snowflakebucket-copyoption/size/';

select * from our_second_db.public.orders; 

TRUNCATE TABLE OUR_SECOND_DB.PUBLIC.ORDERS; 

CREATE OR REPLACE stage manage_db."external_stages"."aws_stage_sizelimits"
url=s3://snowflakebucket-copyoption/size/;

LIST @manage_db."external_stages"."aws_stage_sizelimits";


-- Let's try the size limit option on the copy command
-- the first file is always copied regardless of the size limit
-- the size limit option is the size limit on all the files in the stage that are being copied

CREATE OR REPLACE TABLE  OUR_SECOND_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
    );

SELECT * from OUR_SECOND_DB.PUBLIC.ORDERS;

COPY INTO our_second_db.public.orders
from @manage_db."external_stages"."aws_stage_sizelimits"
pattern = ".*Orders.*"
file_format = (type = csv field_delimiter="," skip_header=1)
--VALIDATION_MODE = "RETURN_ERRORS"; 
--ON_ERORR = "CONTINUE"
SIZE_LIMIT = 60000; 

TRUNCATE table OUR_SECOND_DB.PUBLIC.ORDERS;