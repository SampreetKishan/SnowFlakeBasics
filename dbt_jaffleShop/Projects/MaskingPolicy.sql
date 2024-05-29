-- Masking policy allows certain columns to be masked foe certain users/roles. These can be done using masking policies and then applying those policies on certain columns for certain roles. 


 select * from our_first_db.public.customers; 

 -- let's try to mask the last_name column only for certain roles.

-- let's go ahead and create the roles 
CREATE OR REPLACE ROLE "analyst_full";  -- a role that can see all the columns WITHOUT any masks.

CREATE OR REPLACE ROLE "analyst_intern"; -- a role that should not be allowed to see the last_name column; 

-- let's assign policies to the roles.
GRANT USAGE ON DATABASE OUR_FIRST_DB to "analyst_full"; 
GRANT USAGE ON SCHEMA our_first_db.public to "analyst_full";
GRANT SELECT ON TABLE our_first_db.public.customers  TO "analyst_full"; 
GRANT USAGE ON WAREHOUSE COMPUTE_WH to "analyst_full"; 
grant role "analyst_full" to USER "SAMKISHAN4"; 

GRANT USAGE ON DATABASE OUR_FIRST_DB to "analyst_intern"; 
GRANT USAGE ON SCHEMA our_first_db.public to "analyst_intern"; 
GRANT SELECT ON TABLE our_first_db.public.customers  TO "analyst_intern"; 
GRANT USAGE ON WAREHOUSE COMPUTE_WH to "analyst_intern"; 
grant role "analyst_intern" to USER "SAMKISHAN4"; 

show roles; 

-- let's create the masking policy
-- SYNATAX:  https://docs.snowflake.com/en/user-guide/security-column-ddm-use

CREATE OR REPLACE MASKING POLICY analyst_intern_mask AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('analyst_full','ACCOUNTADMIN') THEN val
    ELSE '##########'
  END;

-- apply the masking policy on the table our_first_db.public.customers on column last_name
ALTER TABLE our_first_db.public.customers MODIFY COLUMN last_name SET MASKING POLICY analyst_intern_mask;

select * from our_first_db.public.customers; 

drop masking policy analyst_intern_mask; -- not possible since the policy is attached to a column


-- Unset masking policy 

--let's first take a look at what columns have been assigned the masking policy

select *
  from table(information_schema.policy_references(policy_name => 'analyst_intern_mask'));

--let's now do the actual unmasking bit
ALTER TABLE our_first_db.public.customers 
modify column last_name
unset masking policy;

-- let's alter the masking policy such that only the first two characters are visible

CREATE OR REPLACE masking policy analyst_intern_mask AS (val string) RETURNS string ->
CASE 
   WHEN CURRENT_ROLE() IN ('analyst_full','ACCOUNTADMIN') THEN val
    ELSE concat(left(val,2),'*******')
  END;


ALTER TABLE our_first_db.public.customers 
modify column last_name
unset masking policy;

-- DROP MASKING POLICY  analyst_intern_mask; 



