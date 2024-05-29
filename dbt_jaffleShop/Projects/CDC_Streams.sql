-- Streams allow us to do CHANGE DATA CAPTURE
-- It utilizes DML(data manipulation language).. essentially inserts, deletes, and updates. 
-- A stream observes a source table. Whenever a change is made on the source table, the stream captures it. 
-- When a stream is then consumed into a target table, the stream becomes empty. 

-- Let's create a source table

CREATE OR REPLACE TABLE customers_info(
    customer_id INT,
    customer_name STRING,
    customer_age INT,
    customer_sex STRING
); 

-- Let's create another source table that will be used to join the above source table.

CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_id INT,
    order_qty INT,
    sales_per_unit INT
); 

-- Let's insert into the first table 

INSERT INTO customers_info values 
    (1, 'Adam',29,'Male'),
    (2, 'Alice',32,'Female'),
    (3, 'Mark',19,'Male'),
    (4, 'Janice',36,'Female'); 

-- Let's insert into the second table 
INSERT INTO orders values 
-- order id, customer_id, order_qty, sales_per_unit
(1,2,3,12 ),
(2,3,2,9 ),
(3,4,10,5 ),
(4,3,2,80 ),
(5,2,2,80 ),
(6,1,10,90 ),
(7,2,20,10 ),
(8,3,10,20) ; 

select * from customers_info; 
select * from orders; 

-- let's combine the two tables 
CREATE OR REPLACE TABLE total_sales (
    order_id INT,
    customer_name STRING,
    customer_age INT,
    order_qty INT,
    total_sales INT
);

select * from customers_info; 
select * from orders; 

INSERT INTO total_sales
SELECT 
    orders.ORDER_ID,
    customers_info.customer_name,
    customers_info.customer_age,
    orders.order_qty,
    orders.order_qty * orders.sales_per_unit as total_sales 
    FROM orders 
    LEFT JOIN customers_info 
    ON orders.customer_id = customers_info.customer_id; 

select * from total_sales; 

-- let's see the sum of total_sales
select sum(total_sales) from total_sales; 
-- Rs 1,724 

-- let's create a stream on the orders table;
CREATE OR REPLACE STREAM orders_stream ON TABLE ORDERS; 

show streams; 

desc stream ORDERS_STREAM; 


--let's see the contents of the stream
select * from orders_stream; 
-- There is nothing in the orders_stream 

--let's insert into the orders table
INSERT INTO orders values 
-- order id, customer_id, order_qty, sales_per_unit
(9,1,3,12 ),
(10,4,2,99 ); 


-- Let's take a look at the stream object now. 
select * from orders_stream; 
-- here metadata$action would be 'insert', metadata$update would be 'false'. 

-- let's get ready to consume the stream into total_sales table
INSERT INTO total_sales
SELECT 
    orders_stream.ORDER_ID,
    customers_info.customer_name,
    customers_info.customer_age,
    orders_stream.order_qty,
    orders_stream.order_qty * orders_stream.sales_per_unit as total_sales 
    FROM orders_stream 
    LEFT JOIN customers_info 
    ON orders_stream.customer_id = customers_info.customer_id; 

select * from total_sales; 
select sum(total_sales) from total_sales; 
-- New sum is Rs 1,958. 

-- let's take a look at the stream
select * from orders_stream;
-- It is empty because it has been consumed into the total_sames table. 


------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
-------------- let's learn about update---------------
-------------- let's learn about update---------------
-------------- let's learn about update---------------
-------------- let's learn about update---------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

select * from customers_info; 
select * from orders;
select * from total_sales; 

-- Let's create a stream on the customers_info table
CREATE OR REPLACE STREAM customers_info_stream
ON TABLE customers_info; 

SHOW streams; 
DESC stream customers_info_stream;

-- Make sure there is nothing in the stream
select * from customers_info_stream; 

select * from total_sales; 

-- make an update to the customers_info table 
UPDATE customers_info 
SET customer_age = 27 where customer_name = 'Adam'; 

-- let's check Adam's age in the total sales table.
select * from total_sales; 
-- It is still 28.. 

-- You can see two rows. One for METADATA$ACTION = 'INSERT' and one for 'DELETE'. Both have METADATA$UPDATE = TRUE


-- let's try to merge the customers_info_stream into the total sales table
MERGE INTO total_sales as target
using customers_info_stream as source 
ON target.customer_name = source.customer_name
WHEN MATCHED
    AND source.METADATA$ACTION = 'INSERT'
    AND source.METADATA$ISUPDATE = TRUE
    THEN
        UPDATE SET
        target.customer_age=source.customer_age;

select * from total_sales; 
-- You can see Adam's age in total_sales has been UPDATED to 27. 



------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
-------------- let's learn about delete---------------
-------------- let's learn about delete---------------
-------------- let's learn about delete---------------
-------------- let's learn about delete---------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

select * from customers_info; 
select * from orders; 
select * from total_sales; 

-- let's say Mark decides to leave. 

SHOW streams; 
DESC stream customers_info_stream; 

DELETE FROM customers_info
WHERE customer_name = 'Mark'; 

-- let's check the customers_info_stream
select * from customers_info_stream; 

-- let's try to merge this with the total_sales table

MERGE INTO total_sales as target
USING customers_info_stream as source 
ON target.customer_name = source.customer_name
WHEN MATCHED 
    AND source.METADATA$ACTION = 'DELETE' 
    AND source.METADATA$ISUPDATE = FALSE 
    THEN 
        DELETE; 

    
-- let's see if entries for 'Mark' exist in the total_sales table        
select * from total_sales where customer_name = 'Mark'; 
-- No.

-- let's make sure the customers_info_stream is empty
select * from customers_info_stream; 


-- let's see if we can write a single merge statement to process all types of changes(inserts, deletes and updates)
select * from orders;
select * from customers_info;
select * from total_sales; 
show streams; 
select * from customers_info_stream; 
select * from orders_stream; 

-- let's try insert
INSERT into orders(order_id, customer_id, order_qty, sales_per_unit) values(11,2,10,4);

-- let's try update
UPDATE orders 
SET order_qty = 100
where order_id = 11; 

--let's try delete
DELETE FROM orders
where order_id = 10; 




--let's assume we only make changes to the orders table and NOT the customers_info table 
MERGE into total_sales as target
USING (
        select orders_stream.order_id as order_id, 
        customers_info.customer_name as customer_name,
        customers_info.customer_age as customer_age,
        orders_stream.order_qty as order_qty, 
        orders_stream.order_qty * orders_stream.sales_per_unit as total_sales,
        orders_stream.METADATA$ACTION,
        orders_stream.METADATA$ISUPDATE
        from orders_stream 
        inner join customers_info ON orders_stream.customer_id = customers_info.customer_id
    )
as source 
ON target.order_id = source.order_id 
WHEN NOT MATCHED 
    AND 
    source.METADATA$ACTION = 'INSERT'
    AND 
    source.METADATA$ISUPDATE = FALSE 
    THEN
        insert (order_id, customer_name, customer_age, order_qty, total_sales) 
        VALUES(source.order_id, source.customer_name, source.customer_age, source.order_qty, source.total_sales)
WHEN MATCHED 
    AND source.METADATA$ACTION = 'INSERT'
    AND source.METADATA$ISUPDATE = TRUE 
    THEN 
        UPDATE SET
            target.order_id = source.order_id,
            target.customer_name = source.customer_name,
            target.customer_age= source.customer_age,
            target. order_qty = source. order_qty,
            target.total_sales = source.total_sales
WHEN MATCHED
    AND source.METADATA$ACTION = 'DELETE'
    AND source.METADATA$ISUPDATE = FALSE
    THEN 
        DELETE;


-- you can create a similar merge statement when the customers_info table's contents change. 



------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
-------------- Combine streams and tasks -------------
-------------- Combine streams and tasks -------------
-------------- Combine streams and tasks -------------
-------------- Combine streams and tasks -------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

SELECT SYSTEM$STREAM_HAS_DATA('orders_stream'); 

CREATE OR REPLACE TASK update_total_sales_table
SCHEDULE = '1 MINUTE'
WAREHOUSE = 'COMPUTE_WH'
COMMENT = 'A task to update total_sales table  by consuming a stream'
WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')
AS
  -- Check if stream has data
    MERGE into total_sales as target
        USING (
                select orders_stream.order_id as order_id, 
                customers_info.customer_name as customer_name,
                customers_info.customer_age as customer_age,
                orders_stream.order_qty as order_qty, 
                orders_stream.order_qty * orders_stream.sales_per_unit as total_sales,
                orders_stream.METADATA$ACTION,
                orders_stream.METADATA$ISUPDATE
                from orders_stream 
                inner join customers_info ON orders_stream.customer_id = customers_info.customer_id
            )
        as source 
        ON target.order_id = source.order_id 
        WHEN NOT MATCHED 
            AND 
            source.METADATA$ACTION = 'INSERT'
            AND 
            source.METADATA$ISUPDATE = FALSE 
            THEN
                insert (order_id, customer_name, customer_age, order_qty, total_sales) 
                VALUES(source.order_id, source.customer_name, source.customer_age, source.order_qty, source.total_sales)
        WHEN MATCHED 
            AND source.METADATA$ACTION = 'INSERT'
            AND source.METADATA$ISUPDATE = TRUE 
            THEN 
                UPDATE SET
                    target.order_id = source.order_id,
                    target.customer_name = source.customer_name,
                    target.customer_age= source.customer_age,
                    target. order_qty = source. order_qty,
                    target.total_sales = source.total_sales
        WHEN MATCHED
            AND source.METADATA$ACTION = 'DELETE'
            AND source.METADATA$ISUPDATE = FALSE
            THEN 
                DELETE;

  


show tasks; 
ALTER TASK UPDATE_TOTAL_SALES_TABLE RESUME; 



-- let's try insert
INSERT into orders(order_id, customer_id, order_qty, sales_per_unit) values(12,4,98,4);

-- let's try update
UPDATE orders 
SET order_qty = 100
where order_id = 12; 

--let's try delete
DELETE FROM orders
where order_id = 1; 

-- let's suspend the task 
ALTER TASK UPDATE_TOTAL_SALES_TABLE SUSPEND;

-- LET'S DROP THE TASK
DROP TASK UPDATE_TOTAL_SALES_TABLE; 



