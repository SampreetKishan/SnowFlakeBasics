-- let's add another stage for 's3://bucketsnowflakes4'

CREATE OR REPLACE STAGE MANAGE_DB."external_stages"."aws_stage_on_error"
url='s3://bucketsnowflakes4'; 

DESC STAGE manage_db."external_stages"."aws_stage_on_error"; 

-- list the files in the stage
list @manage_db."external_stages"."aws_stage_on_error"; 

--- the two files are: 
-- s3://bucketsnowflakes4/OrderDetails_error.csv
-- s3://bucketsnowflakes4/OrderDetails_error2.csv

select * from OUR_FIRST_DB.PUBLIC.ORDERS;

-- let's create a table 
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX(
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
); 

-- let's TRY to load the contents of the stage files into the table that we just created.
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @manage_db."external_stages"."aws_stage_on_error"
files =('OrderDetails_error.csv', 'OrderDetails_error2.csv')
file_format = (type =csv field_delimiter=',' skip_header=1)
ON_ERROR = 'CONTINUE'; 

-- Let's try to explore other ON_ERROR options
-- let's first truncate the contents of the table 

TRUNCATE TABLE our_first_db.public.orders_ex; 

-- let's skip the file with the error(s)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX 
FROM @manage_db."external_stages"."aws_stage_on_error"
files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
file_format = (type = csv field_delimiter = ',' skip_header=1)
ON_ERROR = "SKIP_FILE"

--let's ONLY skip if there's more than 3 errors in the same file.
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX; 

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX 
FROM @manage_db."external_stages"."aws_stage_on_error"
files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
file_format = (type = csv field_delimiter = ',' skip_header=1)
ON_ERROR = "SKIP_FILE_3"


-- Let's skip a file based on a percentage of errors in the rows. Let's say, we skip a file if 3% or more of the rows have an error.
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX; 

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX 
FROM @manage_db."external_stages"."aws_stage_on_error"
files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
file_format = (type = csv field_delimiter = ',' skip_header=1)
ON_ERROR = "SKIP_FILE_3%"; 
