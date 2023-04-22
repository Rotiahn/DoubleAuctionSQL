----------------------
-- Proc name: auc_buyorderlist_validate
-- Proc description: Verify that a relation is valid and complete buy orderlist (any proc which takes a buy order list as an input should accept this buy orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_buyorderlist_validate (table_to_check regclass)
RETURNS BOOLEAN
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

WITH tabledefs AS (
    SELECT * FROM pg_attribute WHERE attrelid=$1::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='buyer_order_list'::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='seller_order_list'::regclass
)

SELECT 
        bool_and(pass)
    AND count(*)=3
FROM (
    SELECT 
        test
        ,type_check AND not_null AS pass
    FROM (
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
    ) AS tests
) all_tests

$$ LANGUAGE SQL
COST 20
;

----------------------
-- Proc name: auc_sellorderlist_validate
-- Proc description: Verify that a relation is valid and complete sell orderlist (any proc which takes a sell order list as an input should accept this sell orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)

CREATE OR REPLACE FUNCTION auc_sellorderlist_validate (table_to_check regclass)
RETURNS BOOLEAN
AS $$

--NOTE: we are using pg_attribute instead of information_schema.columns because we want to be able to validate both views AND tables

WITH tabledefs AS (
    SELECT * FROM pg_attribute WHERE attrelid=$1::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='buyer_order_list'::regclass
--    SELECT * FROM pg_attribute WHERE attrelid='seller_order_list'::regclass
)

SELECT 
        bool_and(pass)
    AND count(*)=3
FROM (
    SELECT 
        test
        ,type_check AND not_null AS pass
    FROM (
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
    ) AS tests
) all_tests

$$ LANGUAGE SQL
COST 20
;


----------------------
-- Proc name auc_create_buyorderlist
-- Proc description: creates an table that meets the criteria of a buyorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_buyorderlist Test 1:  Run validate on name_of_table


----------------------
-- Proc name auc_create_sellorderlist
-- Proc description: creates an table that meets the criteria of a sellorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_sellorderlist Test 1:  Run validate on name_of_table
