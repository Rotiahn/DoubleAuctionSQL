---Example auction of 50 sellers and 100 buyers

DROP TABLE IF EXISTS buyer_order_list CASCADE;
DROP TABLE IF EXISTS seller_order_list CASCADE;
DROP TABLE IF EXISTS transaction_list CASCADE;

CALL auc_create_buyorderlist('buyer_order_list');
CALL auc_create_sellorderlist('seller_order_list');
CALL auc_create_transactionlist('transaction_list');



INSERT INTO buyer_order_list (buyer_id,qty,price)
SELECT 
     buyer_id
    ,sum(qty)
    ,price
FROM
    (
    SELECT 
        buyer_id
        --,buyer_bid_id
        ,CEIL(RANDOM()*100)::INT AS qty
        ,CEIL(RANDOM()*100)::numeric::money AS price
    FROM
        (
            SELECT 
                buyer_id
                ,generate_series(1,CEIL(RANDOM()*1)::INT) AS buyer_bid_id

            FROM
                (SELECT generate_series(1,100) AS buyer_id) as buyer_list

        ) AS buyer_bidlist
    ) AS agg_buyer_bidlist 
GROUP BY
     buyer_id
    ,price
--ON CONFLICT (buyer_id,price) DO UPDATE
--    SET qty = buyer_order_list.qty + excluded.qty
;




INSERT INTO seller_order_list (seller_id,qty,price)
SELECT 
     seller_id
    ,sum(qty)
    ,price
FROM
    (
    SELECT 
        seller_id
        --,seller_bid_id
        ,CEIL(RANDOM()*100)::INT AS qty
        ,CEIL(RANDOM()*100)::numeric::money AS price
    FROM
        (
            SELECT 
                seller_id
                ,generate_series(1,CEIL(RANDOM()*1)::INT) AS seller_bid_id

            FROM
                (SELECT generate_series(1,50) AS seller_id) as seller_list

        ) AS seller_bidlist
    ) AS agg_seller_bidlist 
GROUP BY
     seller_id
    ,price
--ON CONFLICT (seller_id,price) DO UPDATE
--    SET qty = seller_order_list.qty + excluded.qty
;


INSERT INTO transaction_list (type,entity_id,qty,price)
SELECT (auc_run('buyer_order_list','seller_order_list')).*
;



WITH stats AS (
    SELECT 
        type
        ,count(DISTINCT entity_id) AS participants
        ,sum(qty) AS qty
        ,sum(qty*price) AS transaction_amt
    FROM
        transaction_list
    GROUP BY
        type
)
SELECT 
     (SELECT participants from stats where type='buy')  AS buyers
    ,(SELECT participants from stats where type='sell') AS sellers
    ,(SELECT MIN(qty) from stats) AS qty_transacted
    ,(SELECT transaction_amt from stats WHERE type='sell') AS dollars_transfered
    ,(
         (SELECT transaction_amt from stats WHERE type='buy') 
        -(SELECT transaction_amt from stats WHERE type='sell') 
    ) AS auctioneer_profit

;

    
