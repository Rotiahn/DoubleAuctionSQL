
DROP VIEW IF EXISTS order_straddle;

CREATE VIEW order_straddle AS
SELECT 
     buyer.border_id
    ,buyer.buyer_id
    ,buyer.bprice
    ,COALESCE(buyer.item_id,seller.item_id) as item_id
    ,seller.sprice
    ,seller.seller_id
    ,seller.sorder_id
FROM
    (
        SELECT 
            border_id
            ,ROW_NUMBER() OVER(ORDER BY bprice DESC) AS item_id
            ,buyer_id
            ,bprice
        FROM
            (
                SELECT
                    b.order_id::text
                    || '.'::text
                    || generate_series(1,b.qty)::text
                    AS border_id
                    ,buyer_id
                    ,b.price AS bprice
                FROM
                    buyer_order_list b
            ) AS b_orders
    ) AS buyer 
    ,(
        SELECT 
            sorder_id
            ,ROW_NUMBER() OVER(ORDER BY sprice ASC) AS item_id
            ,seller_id
            ,sprice
        FROM
        (
            SELECT
                s.order_id::text
                || '.'::text
                || generate_series(1,s.qty)::text
                AS sorder_id
                ,seller_id
                ,s.price AS sprice
            FROM
                seller_order_list s
        ) AS s_orders
    ) as seller 

WHERE 
    buyer.item_id=seller.item_id
    
;

--EXPLAIN ANALYZE 
--SELECT ((bprice+sprice)/2) FROM order_straddle WHERE item_id=(SELECT max(item_id) from order_straddle WHERE bprice>sprice);

--This one is always faster for finding K
EXPLAIN ANALYZE 
SELECT
     item_id as k
    ,bprice
    ,sprice
FROM order_straddle
WHERE item_id = (SELECT item_id-1 as k FROM order_straddle WHERE bprice>=sprice ORDER BY item_id DESC limit 1)
;

--K at 757379
--bprice =51.00, sprice = 51.00


SELECT 
     count(DISTINCT buyer_id) AS buyers
    ,count(DISTINCT seller_id) AS sellers
    ,max(item_id) as agg_qty
    ,(51*max(item_id))::money AS buyer_cash
    ,(51*max(item_id))::money AS seller_cash
FROM 
    order_straddle
WHERE 
    item_id<=357379
;
    
