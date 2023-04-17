

--Query to generate order list contents

--Buyers: 10
--Bids/Buyer: 1-5
--Min Qty:1
--Max Qty:100
--Max Price: $9.99
--Min Price: $0.01


INSERT INTO buyer_order_list
SELECT 
     buyer_id
    ,buyer_bid_id
    ,CEIL(RANDOM()*100)::INT AS qty
    ,(CEIL(RANDOM()*1000)::numeric::money /100)::money AS price
FROM
    (
        SELECT 
            buyer_id
            ,generate_series(1,CEIL(RANDOM()*5)::INT) AS buyer_bid_id

        FROM
            (SELECT generate_series(1,10) AS buyer_id) as buyer_list

    ) AS buyer_bidlist
;
