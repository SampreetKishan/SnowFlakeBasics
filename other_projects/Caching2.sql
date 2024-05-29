select * from snowflake_sample_data.tpch_sf1.customer limit 10; 

-- UPDATE snowflake_sample_data.tpch_sf1.customer 
-- SET C_ADDRESS  = '9Ii4zQn9cX_version2'
-- WHERE C_NAME = 'Customer#000060001' AND C_ACCTBAL = '9957.56'; 

SHOW ROLES; 
SHOW GRANTS TO ROLE "data_scientists"; 

CREATE USER "DS2" 
LOGIN_NAME = 'DS2'
PASSWORD = 'DS2_password'
COMMENT = '2nd Data scientist with data_scientists role'; 

GRANT ROLE "data_scientists" TO USER "DS2"; 

DROP USER "DS2"; 
DROP USER "DS1"; 