select * from our_second_db.information_schema.load_history;

select * from snowflake.account_usage.load_history where table_name = 'ORDERS_EX'; 

select table_id, date(last_load_time) from snowflake.account_usage.load_history where table_name = 'ORDERS_EX' and date(last_load_time) <= dateadd(days, -1 , current_date); 


