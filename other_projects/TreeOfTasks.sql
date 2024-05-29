-- A tree of tasks is essentially a chain of tasks.
-- A root task is the first task that needs to be executed in a tree of tasks.
-- A root task can then be followed by one or more child tasks. 


-- Let's create a root task

SHOW TASKS; 

CREATE OR REPLACE TASK root_task
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '1 MINUTE'
AS
INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_DATE); 


-- create child task 1

SELECT * FROM CUSTOMERS; 

CREATE OR REPLACE TASK "child_task_1"
warehouse = 'COMPUTE_WH'
AFTER root_task
AS 
INSERT INTO CUSTOMERS(CREATE_DATE,FIRST_NAME) VALUES(CURRENT_DATE, 'FirstGuy'); 

show tasks; 

ALTER TASK root_task suspend; 
ALTER TASK "child_task_1" RESUME; 
ALTER TASK root_task RESUME; 

select * from customers;

-- CREATE child task 2
--got to suspend root task before create a child task 
ALTER TASK root_task suspend; 


CREATE OR REPLACE task "child_task_2"
WAREHOUSE = 'COMPUTE_WH'
AFTER root_task
AS
INSERT INTO CUSTOMERS(CREATE_DATE,FIRST_NAME) VALUES(CURRENT_DATE, 'SecondGuy'); 

ALTER TASK "child_task_2" RESUME; 
ALTER TASK root_task RESUME; 
SHOW TASKS;

SELECT * FROM CUSTOMERS; 

SHOW tasks;

ALTER TASK root_task SUSPEND; 
ALTER TASK "child_task_2" SUSPEND; 
ALTER TASK "child_task_1" SUSPEND; 
