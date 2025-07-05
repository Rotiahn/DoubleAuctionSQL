CREATE EXTENSION "DoubleAuctionSQL";

---Example auction of 50 sellers and 100 buyers

DROP TABLE IF EXISTS buyer_order_list CASCADE;
DROP TABLE IF EXISTS seller_order_list CASCADE;
DROP TABLE IF EXISTS transaction_list CASCADE;

CALL auc_create_buyorderlist('buyer_order_list');
CALL auc_create_sellorderlist('seller_order_list');
CALL auc_create_transactionlist('transaction_list');



INSERT INTO buyer_order_list (buyer_id,product_id,qty,price)
SELECT 
     buyer_id
    ,product_id
    ,sum(qty)
    ,price
FROM
    (
    SELECT 
        buyer_id
        ,product_id
        --,buyer_bid_id
        ,CEIL(RANDOM()*100)::INT AS qty
        ,CEIL(RANDOM()*100)::numeric::money AS price
    FROM
        (
            SELECT 
                buyer_id
                ,generate_series(1,CEIL(RANDOM()*1)::INT) AS buyer_bid_id
                ,CEIL(RANDOM()*5)::INT AS product_id

            FROM
                (SELECT generate_series(1,100) AS buyer_id) as buyer_list

        ) AS buyer_bidlist
    ) AS agg_buyer_bidlist 
GROUP BY
     buyer_id
    ,product_id
    ,price
--ON CONFLICT (buyer_id,price) DO UPDATE
--    SET qty = buyer_order_list.qty + excluded.qty
;




INSERT INTO seller_order_list (seller_id,product_id,qty,price)
SELECT 
     seller_id
    ,product_id
    ,sum(qty)
    ,price
FROM
    (
    SELECT 
        seller_id
        ,product_id
        --,seller_bid_id
        ,CEIL(RANDOM()*100)::INT AS qty
        ,CEIL(RANDOM()*100)::numeric::money AS price
    FROM
        (
            SELECT 
                seller_id
                ,generate_series(1,CEIL(RANDOM()*1)::INT) AS seller_bid_id
                ,CEIL(RANDOM()*5)::INT AS product_id

            FROM
                (SELECT generate_series(1,50) AS seller_id) as seller_list

        ) AS seller_bidlist
    ) AS agg_seller_bidlist 
GROUP BY
     seller_id
    ,product_id
    ,price
--ON CONFLICT (seller_id,price) DO UPDATE
--    SET qty = seller_order_list.qty + excluded.qty
;


INSERT INTO transaction_list (type,product_id,entity_id,qty,price)
SELECT (auc_run('buyer_order_list','seller_order_list')).*
;



WITH buyers AS (
    SELECT 
        type
        ,product_id
        ,count(DISTINCT entity_id) AS participants
        ,sum(qty) AS qty
        ,sum(qty*price) AS transaction_amt
    FROM
        transaction_list
    WHERE 
        type='buy'
    GROUP BY
        type
        ,product_id
),sellers AS (
    SELECT 
        type
        ,product_id
        ,count(DISTINCT entity_id) AS participants
        ,sum(qty) AS qty
        ,sum(qty*price) AS transaction_amt
    FROM
        transaction_list
    WHERE 
        type='sell'
    GROUP BY
        type
        ,product_id
)
SELECT 
     buyers.product_id
    ,buyers.participants AS buyers
    ,sellers.participants AS sellers
    ,sellers.qty AS qty_transacted
    ,buyers.qty - sellers.qty AS extra_demand
    ,sellers.transaction_amt AS dollars_transfered
    ,buyers.transaction_amt - sellers.transaction_amt AS auctioneer_profit
FROM
    buyers
    ,sellers
WHERE   
        buyers.product_id = sellers.product_id
;

    
