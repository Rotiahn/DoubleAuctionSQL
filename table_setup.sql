


DROP TABLE IF EXISTS buyer_order_list CASCADE;

--CREATE TABLE buyer_order_list (
--     order_id   SERIAL  
--    ,buyer_id   INT     NOT NULL
--    ,qty        INT     NOT NULL
--    ,price      money   NOT NULL
--
--    ,UNIQUE(buyer_id,price)
--    )
--;
CALL auc_create_buyorderlist('buyer_order_list');

DROP TABLE IF EXISTS seller_order_list CASCADE;

--CREATE TABLE seller_order_list (
--     order_id   SERIAL  
--    ,seller_id  INT     NOT NULL
--    ,qty        INT     NOT NULL
--    ,price      money   NOT NULL
--
--    ,UNIQUE(seller_id,price)
--    )
--;
CALL auc_create_sellorderlist('seller_order_list');

DROP TABLE IF EXISTS transaction_list CASCADE;
--CREATE TABLE transaction_list (
--    transact_id     SERIAL
--    ,type           text NOT NULL --('buy' or 'sell')
--    ,entity_id      INT NOT NULL --buyer_id or seller_id depending on type
--    ,qty            INT NOT NULL
--    ,price          money NOT NULL
--
--)
--;
CALL auc_create_transactionlist('transaction_list');
