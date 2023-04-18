
DROP VIEW IF EXISTS order_straddle;

CREATE VIEW order_straddle AS
SELECT
     sum(b.qty) AS buy_qty
    ,COALESCE(b.price,s.price) AS price
    ,sum(s.qty) AS sell_qty
FROM
    buyer_order_list b
    FULL OUTER JOIN seller_order_list s ON (b.price=s.price)
GROUP BY
    COALESCE(b.price,s.price) 
ORDER BY 
    COALESCE(b.price,s.price) DESC
;

