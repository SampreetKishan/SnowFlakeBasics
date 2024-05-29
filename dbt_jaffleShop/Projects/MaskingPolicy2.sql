-- 1. Prepare the table and two roles to test the masking policies (you can use the statement below)
-- Prepare table --
create or replace table customers(
  id number,
  full_name varchar, 
  email varchar,
  phone varchar,
  spent number,
  create_date DATE DEFAULT CURRENT_DATE);
 
 
-- insert values in table --
insert into customers (id, full_name, email,phone,spent)
values
  (1,'Lewiss MacDwyer','lmacdwyer0@un.org','262-665-9168',140),
  (2,'Ty Pettingall','tpettingall1@mayoclinic.com','734-987-7120',254),
  (3,'Marlee Spadazzi','mspadazzi2@txnews.com','867-946-3659',120),
  (4,'Heywood Tearney','htearney3@patch.com','563-853-8192',1230),
  (5,'Odilia Seti','oseti4@globo.com','730-451-8637',143),
  (6,'Meggie Washtell','mwashtell5@rediff.com','568-896-6138',600);
 
 
-- set up roles
CREATE OR REPLACE ROLE ANALYST_MASKED;
CREATE OR REPLACE ROLE ANALYST_FULL;
 
-- grant select on table to roles
GRANT USAGE ON DATABASE  OUR_FIRST_DB TO ROLE ANALYST_MASKED;
GRANT USAGE ON DATABASE  OUR_FIRST_DB TO ROLE ANALYST_FULL;

GRANT USAGE ON SCHEMA  OUR_FIRST_DB.PUBLIC TO ROLE ANALYST_MASKED;
GRANT USAGE ON SCHEMA  OUR_FIRST_DB.PUBLIC TO ROLE ANALYST_FULL;

GRANT SELECT ON TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_MASKED;
GRANT SELECT ON TABLE  OUR_FIRST_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_FULL;
 

 
-- grant warehouse access to roles
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_MASKED;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_FULL;
 
-- assign roles to a user
GRANT ROLE ANALYST_MASKED TO USER "SAMKISHAN4";
GRANT ROLE ANALYST_FULL TO USER "SAMKISHAN4";

-- 2. Create masking policy called name that is showing '***' instead of the original varchar value except the role analyst_full is used in this case show the original value.

select * from customers; 


CREATE OR REPLACE MASKING POLICY name AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('ANALYST_FULL') THEN val
    ELSE '***'
  END;
  
-- 3. Apply the masking policy on the column full_name

  ALTER TABLE customers modify column full_name
  SET MASKING POLICY name; 
  
-- 4. Unset the policy
  ALTER TABLE customers modify column full_name
  UNSET MASKING POLICY; -- name; 


  -- 5. Validate the result using the role analyst_masked and analyst_full
  select * from customers; 
 -- All good.

 --6. Alter the policy so that the last two characters are shown and before that only '***' (example: ***er)

 SHOW MASKING POLICIES; 
 
 ALTER MASKING POLICY NAME SET BODY ->
  CASE
    WHEN current_role() IN ('ANALYST_FULL') THEN VAL
    ELSE CONCAT('***',RIGHT(VAL,2))
  END;


  
--7. Apply the policy again on the column full name and validate the policy
    ALTER TABLE customers modify column full_name
  SET MASKING POLICY name; 

    select * from customers; 
  