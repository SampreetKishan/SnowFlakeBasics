-- Let's learn about how Snowflake optimizes querying
-- Let's learn about Caching

select * from snowflake_sample_data.tpch_sf1.customer limit 10; 
-- Query 01b34fae-3201-09b6-0007-8a4200042126
-- Total time: 2.1s

select sum(C_ACCTBAL) from snowflake_sample_data.tpch_sf1.customer; 
-- Query 01b34fb0-3201-09b6-0007-8a420004213e
-- Total time: 1.5s

-- If we were to run the same queries again, the time to get the results will be much less since Snowflake caches the results. 

-- let's run the same queries again
select * from snowflake_sample_data.tpch_sf1.customer limit 10; 
-- Query 01b34fb1-3201-0a13-0007-8a42000400b6
-- Total time: 86ms 
-- Look at the query details, you will see "Query result reuse". 

select sum(C_ACCTBAL) from snowflake_sample_data.tpch_sf1.customer; 
--Query 01b34fb2-3201-0a13-0007-8a42000400ca
-- Total time: 58ms 