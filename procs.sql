--Nuke All Functions and Procedures
DROP FUNCTION  IF EXISTS auc_validate_buyorderlist_verbose;
DROP FUNCTION  IF EXISTS auc_validate_buyorderlist;
DROP FUNCTION  IF EXISTS auc_validate_sellorderlist_verbose;
DROP FUNCTION  IF EXISTS auc_validate_sellorderlist;
DROP PROCEDURE IF EXISTS auc_create_buyorderlist;
DROP PROCEDURE IF EXISTS auc_create_sellorderlist;



----------------------
-- Proc name: auc_buyorderlist_validate_verbose
-- Proc description: Verify that a relation is valid and complete buy orderlist (any proc which takes a buy order list as an input should accept this buy orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_validate_buyorderlist_verbose (table_to_check regclass)
RETURNS TABLE (test TEXT, type_check BOOLEAN, not_null BOOLEAN)
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

WITH tabledefs AS (
    SELECT * FROM pg_attribute WHERE attrelid=$1::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='buyer_order_list'::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='seller_order_list'::regclass
)

--Check buyer_id is INT NOT NULL
SELECT 
    'buyer_id' AS test
    ,td.atttypid IN (20,21,23) AS type_check --(int8,int2,int4)
    ,attnotnull AS not_null
    --,* 
FROM tabledefs td
WHERE attname='buyer_id'

UNION ALL
--Check qty is INT NOT NULL
SELECT 
    'qty' AS test
    ,td.atttypid IN (20,21,23) AS type_check --(int8,int2,int4)
    ,attnotnull AS not_null
    --,* 
FROM tabledefs td
WHERE attname='qty'

UNION ALL
--Check price is money NOT NULL
SELECT 
    'price' AS test
    ,td.atttypid IN (790) AS type_check --(money)
    ,attnotnull AS not_null
    --,* 
FROM tabledefs td
WHERE attname='price'

$$ LANGUAGE SQL
COST 10
STABLE
;



----------------------
-- Proc name: auc_buyorderlist_validate
-- Proc description: Verify that a relation is valid and complete buy orderlist (any proc which takes a buy order list as an input should accept this buy orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_validate_buyorderlist (table_to_check regclass)
RETURNS BOOLEAN
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

SELECT 
        bool_and(pass)
    AND count(*)=3
FROM (
    SELECT 
        test
        ,type_check AND not_null AS pass
    FROM (
       SELECT (auc_validate_buyorderlist_verbose($1)).*
       --SELECT (auc_validate_buyorderlist_verbose('buy_orders')).*
    ) AS tests
) all_tests

$$ LANGUAGE SQL
STABLE
;

----------------------
-- Proc name: auc_sellorderlist_validate_verbose
-- Proc description: Verify that a relation is valid and complete sell orderlist (any proc which takes a sell order list as an input should accept this sell orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_validate_sellorderlist_verbose (table_to_check regclass)
RETURNS TABLE (test TEXT, type_check BOOLEAN, not_null BOOLEAN)
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

WITH tabledefs AS (
    SELECT * FROM pg_attribute WHERE attrelid=$1::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='buyer_order_list'::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='seller_order_list'::regclass
)

        --Check seller_id is INT NOT NULL
        SELECT 
            'seller_id' AS test
            ,td.atttypid IN (20,21,23) AS type_check --(int8,int2,int4)
            ,attnotnull AS not_null
            --,* 
        FROM tabledefs td
        WHERE attname='seller_id'

        UNION ALL
        --Check qty is INT NOT NULL
        SELECT 
            'qty' AS test
            ,td.atttypid IN (20,21,23) AS type_check --(int8,int2,int4)
            ,attnotnull AS not_null
            --,* 
        FROM tabledefs td
        WHERE attname='qty'

        UNION ALL
        --Check price is money NOT NULL
        SELECT 
            'price' AS test
            ,td.atttypid IN (790) AS type_check --(money)
            ,attnotnull AS not_null
            --,* 
        FROM tabledefs td
        WHERE attname='price'

$$ LANGUAGE SQL
COST 10
STABLE
;


----------------------
-- Proc name: auc_sellorderlist_validate
-- Proc description: Verify that a relation is valid and complete sell orderlist (any proc which takes a sell order list as an input should accept this sell orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_validate_sellorderlist (table_to_check regclass)
RETURNS BOOLEAN
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

SELECT 
        bool_and(pass)
    AND count(*)=3
FROM (
    SELECT 
        test
        ,type_check AND not_null AS pass
    FROM (
        SELECT (auc_validate_sellorderlist_verbose($1)).*
    ) AS tests
) all_tests

$$ LANGUAGE SQL
STABLE
;

----------------------
-- Proc name auc_create_buyorderlist
-- Proc description: creates an table that meets the criteria of a buyorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_buyorderlist Test 1:  Run validate on name_of_table

CREATE OR REPLACE PROCEDURE auc_create_buyorderlist (tablename varchar(30))
AS $$

BEGIN
    EXECUTE format('
        CREATE TABLE %I (
        order_id   SERIAL  
        ,buyer_id   INT     NOT NULL
        ,qty        INT     NOT NULL
        ,price      money   NOT NULL

        ,UNIQUE(buyer_id,price)
        )
        ;
    ', tablename)
;
END

$$ LANGUAGE PLPGSQL
;


----------------------
-- Proc name auc_create_sellorderlist
-- Proc description: creates an table that meets the criteria of a sellorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_sellorderlist Test 1:  Run validate on name_of_table


CREATE OR REPLACE PROCEDURE auc_create_sellorderlist (tablename varchar(30))
AS $$

BEGIN
    EXECUTE format('
        CREATE TABLE %I (
            order_id   SERIAL  
            ,seller_id  INT     NOT NULL
            ,qty        INT     NOT NULL
            ,price      money   NOT NULL

            ,UNIQUE(seller_id,price)
            )
        ;
    ', tablename)
;
END

$$ LANGUAGE PLPGSQL
;
