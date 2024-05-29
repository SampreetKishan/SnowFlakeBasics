select count(*) from snowflake.account_usage.storage_usage; 

select 
USAGE_DATE,
STORAGE_BYTES / (1024*1024*1024) AS STORAGE_GB,
STAGE_BYTES /  (1024*1024*1024) AS STAGE_GB,
FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_GB
from snowflake.account_usage.storage_usage; 


SELECT COUNT(*) from snowflake.account_usage.table_storage_metrics;
SELECT * from snowflake.account_usage.table_storage_metrics;

SELECT 
TABLE_NAME,
TABLE_CATALOG AS DB,
ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_GB,
TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_GB,
FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_GB,
DELETED,
TABLE_CREATED
from snowflake.account_usage.table_storage_metrics order by STORAGE_GB DESC; 