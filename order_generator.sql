

--Query to generate order list contents

--Buyers: 10
--Bids/Buyer: 1-5
--Min Qty:1
--Max Qty:100
--Max Price: $100
--Min Price: $1


INSERT INTO buyer_order_list (buyer_id,qty,price)
SELECT 
     buyer_id
    --,buyer_bid_id
    ,CEIL(RANDOM()*100)::INT AS qty
    ,CEIL(RANDOM()*100)::numeric::money AS price
FROM
    (
        SELECT 
            buyer_id
            ,generate_series(1,CEIL(RANDOM()*5)::INT) AS buyer_bid_id

        FROM
            (SELECT generate_series(1,10) AS buyer_id) as buyer_list

    ) AS buyer_bidlist
;




INSERT INTO seller_order_list (seller_id,qty,price)
SELECT 
     seller_id
    --,seller_bid_id
    ,CEIL(RANDOM()*100)::INT AS qty
    ,CEIL(RANDOM()*100)::numeric::money AS price
FROM
    (
        SELECT 
            seller_id
            ,generate_series(1,CEIL(RANDOM()*5)::INT) AS seller_bid_id

        FROM
            (SELECT generate_series(1,10) AS buyer_id) as seller_list

    ) AS seller_bidlist
;
