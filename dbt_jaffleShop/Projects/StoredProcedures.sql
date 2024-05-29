
CREATE OR REPLACE DATABASE OUR_FIRST_DB; 

-- Create a simple table called customers
CREATE OR REPLACE TABLE customers(
    id int AUTOINCREMENT START = 1 INCREMENT =1,
    first_name string, 
    last_name string,
    dt date 
); 



-- CREATE A SIMPLE STORED PROCEDURE TO MULTIPLY TWO NUMBERS
CREATE OR REPLACE PROCEDURE MULTIPLIER(num_1 int, num_2 int)
    RETURNS INT
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    PACKAGES = ('snowflake-snowpark-python')
    HANDLER = 'multiplier'
    AS
$$
def multiplier(session, a,b):
    return a*b
$$ ;

CALL MULTIPLIER(90,100); 

-- A procedure that gives us information about the current session

CREATE OR REPLACE PROCEDURE CURRENT_SESS()
RETURNS STRING
LANGUAGE PYTHON
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'current_sess'
RUNTIME_VERSION = '3.8'
AS
$$
def current_sess(session):
    return session.sql("select current_user(), current_warehouse(), current_database()").collect()
$$

call CURRENT_SESS(); 

--- let's try to create a procedure that adds a new entry into the customers table every time we call it

CREATE OR REPLACE PROCEDURE add_customer(first_name string, last_name string, dt DATE)
returns string
language python
packages = ('snowflake-snowpark-python')
runtime_version = '3.8'
handler = 'add_customer_handler'
execute as owner
AS
$$
from snowflake.snowpark.functions import col

def add_customer_handler(session, f_name, l_name, dt):  
    sql_command = 'INSERT INTO OUR_FIRST_DB.PUBLIC.CUSTOMERS(first_name, last_name, dt) VALUES(\'{}\',\'{}\', \'{}\')'.format(str(f_name), str(l_name), dt)
    print(sql_command)
    session.sql(sql_command).collect()
    return sql_command
$$;

CALL add_customer('Hola','User', CURRENT_DATE);

select * from customers;

-- Let's create a task that execute the above procedure every minute 

CREATE OR REPLACE TASK update_customer
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '1 MINUTE'
COMMENT = 'Task to execute procedure add_customer every minute'
AS
CALL add_customer('Hola', CURRENT_USER, CURRENT_DATE);

SHOW TASKS;
ALTER TASK update_customer RESUME; 
select * from customers; 
ALTER TASK update_customer SUSPEND;  

--stored procedure to display customers

CREATE OR REPLACE PROCEDURE display_customers()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
handler = 'display_cus'
execute as owner 
AS
$$
def display_cus(session):
    customers = session.sql('select * from OUR_FIRST_DB.PUBLIC.CUSTOMERS').collect()
    print(customers)
    return customers
$$;

CALL display_customers(); 


--Create a procedure to create a new table and add users to it.

CREATE OR REPLACE PROCEDURE final_boss()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'final_boss'
packages = ('snowflake-snowpark-python')
AS 
$$
def final_boss(session):
    table_exist = session.sql('''
        SHOW TABLES LIKE \'%customers_2%\'
    ''').collect()
    if(len(table_exist)==0):
        session.sql('''
            CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS_2(
                id int AUTOINCREMENT START = 1 INCREMENT =1,
                name STRING,
                dt DATE
            );
        ''').collect()

    session.sql('''
        INSERT INTO OUR_FIRST_DB.PUBLIC.CUSTOMERS_2(name, dt) 
        VALUES(CURRENT_USER, CURRENT_DATE)
    
    ''').collect()

    return "Successful Insertion"
$$;
CALL final_boss();


select * from our_first_db.public.customers_2; 

-- Create a task to run final_boss every minute
CREATE OR REPLACE task final_boss_task
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '1 MINUTE'
COMMENT = 'Task to execute the final_boss procedure to add user data into the customers_2 data every minute'
AS 
CALL final_boss(); 

SHOW TASKS; 
ALTER TASK FINAL_BOSS_TASK RESUME; 
ALTER TASK FINAL_BOSS_TASK SUSPEND; 

select * from our_first_db.public.customers_2; 

-- Drop both tasks 
DROP TASK FINAL_BOSS_TASK; 
DROP TASK UPDATE_CUSTOMER; 
SHOW TASKS; 


-- Let's restart the tasks so we can learn about task error handling
SHOW TASKS;


SELECT * FROM TABLE(INFORMATION_SCHEMA.task_history()) 
WHERE NAME ='UPDATE_CUSTOMER'
order by scheduled_time desc; 
-- You can see scheduled, successful, and failed task runs. You can also see any error messages that the task would've encountered.
-- You can also filter by when the query was scheduled to run. 

SELECT * FROM CUSTOMERS; 



-- Let's go ahead and drop all the tasks. 
DROP TASK FINAL_BOSS_TASK; 
DROP TASK UPDATE_CUSTOMER; 