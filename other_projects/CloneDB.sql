-- this lecture we will be cloning database objects (database, schemas, tables)

-- let's work with this permanent table
Select * FROM our_first_db.public."employees"; 

-- let's create a clone of this permanent table
CREATE OR REPLACE TABLE our_first_db.public."employees_clone"
CLONE our_first_db.public."employees"; 

select * from our_first_db.public."employees_clone"; 

-- let's alter the contents of the employees_clone table

UPDATE our_first_db.public."employees_clone"
SET first_name = 'Randomios'
where ID = 1; 

select * from our_first_db.public."employees_clone" where id =1; 

-- lets compare it with the table "employees"
select * from our_first_db.public."employees" where id=1; 


-- Note: you can't clone a temporary table into a permanent table. However, you can clone a temporary table into another temporary table.
DROP table our_first_db.public."employees_clone"; 


-- let's clone schemas 

CREATE OR REPLACE TRANSIENT SCHEMA OUR_FIRST_DB."PUBLIC_CLONE"
CLONE our_first_db.public; 

DROP schema our_first_db.public_clone; 

-- let's clone our external stages schema from manage_db into our_first_db database

CREATE OR REPLACE TRANSIENT SCHEMA OUR_FIRST_DB."external_stages"
clone manage_db."external_stages"; 

DROP schema our_first_db."external_stages"; 


-- let's clone database 

CREATE OR REPLACE TRANSIENT DATABASE "OUR_FIRST_DB_CLONE"
CLONE our_first_db;

select * from our_first_db_clone.public.orders; 

DROP DATABASE OUR_FIRST_DB_CLONE; 
