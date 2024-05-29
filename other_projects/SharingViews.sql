--s3://data-snowflake-fundamentals/time-travel/

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_sharingViews"
url = 's3://data-snowflake-fundamentals/time-travel/'; 

LIST @manage_db."external_stages"."aws_sharingViews"; 

SELECT $1, $2, $3, $4, $5, $6, $7, $8 from @manage_db."external_stages"."aws_sharingViews"; 

CREATE OR REPLACE TABLE our_first_db.public.customers(
    id string,
    first_name string,
    last_name string,
    email string,
    gender string,
    job string, 
    phone string
); 


COPY INTO our_first_db.public.customers
FROM @manage_db."external_stages"."aws_sharingViews"
file_format = (type =csv skip_header=1 FIELD_DELIMITER=',')
files = ('customers.csv'); 

-- CREATE A REGULAR VIEW
CREATE OR REPLACE VIEW our_first_db.public.data_job_customers 
AS
SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS WHERE JOB LIKE '%Data%'; 

SELECT * FROM OUR_FIRST_DB.PUBLIC.data_job_customers; 

GRANT USAGE on warehouse compute_wh TO ROLE PUBLIC; 
GRANT USAGE ON database OUR_FIRST_DB TO ROLE PUBLIC; 
GRANT USAGE ON SCHEMA OUR_FIRST_DB.PUBLIC TO ROLE PUBLIC;
GRANT SELECT on view our_first_db.public.data_job_customers to role public; 

show views like '%customers%';

--unfortunately when you run the show views command you can see how the view was created under the 'text' field.
-- SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS WHERE JOB LIKE '%Data%'; 
-- this is not safe and can be a security risk. 


--let's create a secure view

CREATE OR REPLACE SECURE VIEW our_first_db.public.data_job_customers_secure
AS 
SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS WHERE JOB LIKE '%Data%'; 

grant select on view our_first_db.public.data_job_customers_secure to role public; 

-- Fortunately, using a secure view, the 'text' field is empty so no one can tell how the view was created. 

-- let's create a share

CREATE OR REPLACE SHARE SharingViews_Share; 
GRANT USAGE ON DATABASE our_first_db to share SharingViews_Share;
GRANT USAGE ON SCHEMA our_first_db.public to share SharingViews_Share;
GRANT select on view our_first_db.public.data_job_customers TO SHARE SharingViews_Share;
-- Fortunately, we cannot share normal/unsecure views 

GRANT select on view our_first_db.public.data_job_customers_secure TO SHARE SharingViews_Share;
-- Only secure views can be shared.


ALTER SHARE SharingViews_Share
ADD ACCOUNT ="LJMEWNH.DO40197"
SHARE_RESTRICTIONS=FALSE; 






