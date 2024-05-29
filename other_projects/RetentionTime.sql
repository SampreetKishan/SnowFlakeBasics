-- Let's talk about retention time
-- By default, time travel allows you to travel back 1 day 
-- However, you can travel back up to 90 days with the non-basic editions of Snowflake.

CREATE OR REPLACE TABLE our_first_db.public."Customers_sample"(
    id string,
    first_name string,
    last_name string,
    email string,
    country string
)
 alter TABLE our_first_db.public."Customers_sample"
 SET DATA_RETENTION_TIME_IN_DAYS =0; 

SHOW tables like '%Customers_sample%'; --   where ; 

DROP TABLE our_first_db.public."Customers_sample"; 

UNDROP TABLE our_first_db.public."Customers_sample"; 

--- Time travel cost

SELECT  
TABLE_NAME, 
TABLE_SCHEMA,
TABLE_CATALOG AS db,
ACTIVE_BYTES / (1024 * 1024 * 102) as storage_used_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY storage_used_gb desc; 

DROP TABLE OUR