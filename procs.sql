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






----------------------
-- Proc name auc_findk
-- Proc description: Finds the optimum qty k that generates the most transactions while remaining cash surplus for auctioneer
-- Proc inputs: buyorderlist,sellorderlist
-- Proc outputs: transact_qty,bprice,sprice
-- EX: SELECT (auc_findk('buyer_order_list','seller_order_list')).*

CREATE OR REPLACE FUNCTION auc_findk(
     buyorderlist text
    ,sellorderlist text
)
RETURNS 
TABLE (
     transact_qty BIGINT
    ,bprice money
    ,sprice money
)
AS $$


BEGIN
    ASSERT auc_validate_buyorderlist(buyorderlist),   FORMAT('BuyOrderList not validated: %I',buyorderlist);
    ASSERT auc_validate_sellorderlist(sellorderlist), FORMAT('SellOrderList not validated: %I',sellorderlist);


    RETURN QUERY
    EXECUTE '
        WITH order_straddle AS (
        SELECT 
            buyer.bprice
            ,COALESCE(buyer.item_id,seller.item_id) as item_id
            ,seller.sprice
        FROM
            (
                SELECT 
                    ROW_NUMBER() OVER(ORDER BY bprice DESC) AS item_id
                    ,bprice
                FROM
                    (
                        SELECT
                            b.order_id
                            ,generate_series(1,b.qty)
                            ,buyer_id
                            ,b.price AS bprice
                        FROM
                            '|| buyorderlist ||' b
                    ) AS b_orders
            ) AS buyer 
            ,(
                SELECT 
                    ROW_NUMBER() OVER(ORDER BY sprice ASC) AS item_id
                    ,sprice
                FROM
                (
                    SELECT
                        s.order_id
                        ,generate_series(1,s.qty)
                        ,seller_id
                        ,s.price AS sprice
                    FROM
                        '|| sellorderlist ||' s
                ) AS s_orders
            ) as seller 

        WHERE 
            buyer.item_id=seller.item_id

        )
        SELECT
            item_id as transact_qty
            ,bprice
            ,sprice
        FROM order_straddle
        WHERE item_id = (SELECT item_id-1 as k FROM order_straddle WHERE bprice>=sprice ORDER BY item_id DESC limit 1)
        '
    ;

    
    
END
$$ LANGUAGE PLPGSQL
STABLE
;
