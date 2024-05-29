select * from our_second_db.public.orders; 


-- By default database objects like database, schemas, tables are permanent.
-- Permanent tables have time travel (0-90 days), and fail safe. 

CREATE OR REPLACE TABLE our_first_db.public."orders"(
    ORDER_ID STRING,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY STRING,
    SUBCATEGORY STRING
); 

USE DATABASE OUR_FIRST_DB; 
USE SCHEMA PUBLIC; 
SHOW TABLES LIKE '%orders%'; 
DROP TABLE our_first_db.public."orders"; 
UNDROP TABLE our_first_db.public."orders"; 

INSERT INTO our_first_db.public."orders"
select * from our_second_db.public.orders; 
DROP TABLE our_first_db.public."orders"; 

CREATE DATABASE "PDB";
DROP DATABASE "PDB"; 


-- Transient objects have time travel (0-1 day), but no fail safe.
-- They are useful for development work. Because there is no fail safe(additional storage), the costs are lower than permanent objects.



CREATE OR REPLACE TRANSIENT TABLE OUR_FIRST_DB.PUBLIC."orders_transient"(
    ORDER_ID STRING,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY STRING,
    SUBCATEGORY STRING
); 

use database our_first_db; 
use schema public; 

SHOW TABLES like '%orders%';

INSERT INTO our_first_db.public."orders_transient"
SELECT * FROM our_second_db.public.orders; 

create transient database "Transient_db";
use database "Transient_db"; 
show databases ;

-- DROP DATABASE "Transient_db"; 

CREATE OR REPLACE table "Transient_db".public."orders"(
    ORDER_ID STRING,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY STRING,
    SUBCATEGORY STRING

); 


show tables; 
alter table "orders"
set DATA_RETENTION_TIME_IN_DAYS = 1; 

-- Temporary objects have time travel of 0-1 day. However, they don't have fail safe.
-- They are also specific to a session/worksheet. They aren't visible to other users.
-- They are also useful for development purposes and help lower costs. 

CREATE OR REPLACE TEMPORARY TABLE our_first_db.public."orders_temporary"(
    ORDER_ID STRING,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY STRING,
    SUBCATEGORY STRING

); 

USE DATABASE our_first_db; 
USE SCHEMA public; 

SHOW tables like '%orders%'; 

insert into our_first_db.public."orders_temporary"
select * from our_second_db.public.orders; 

select * from our_first_db.public."orders_temporary" limit 10;

-- The above query will run in this worksheet. However, if you change your role and/or change into another worksheet, this table won't exist/be visible for the other worksheet/role. 


DROP TABLE OUR_FIRST_DB.PUBLIC."orders_transient"; 
DROP TABLE OUR_FIRST_DB.PUBLIC."orders_temporary"; 





























