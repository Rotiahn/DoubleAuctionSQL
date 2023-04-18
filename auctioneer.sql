
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

CREATE VIEW agg_straddle AS
SELECT 
     agg_demand.agg_buy
    ,o.buy_qty
    ,COALESCE(agg_demand.price,agg_supply.price) as price
    ,o.sell_qty
    ,agg_supply.agg_sell
    ,LEAST(
         COALESCE(agg_buy,0)
        ,COALESCE(agg_sell,0)
    ) AS max_transact 
FROM
    order_straddle o
    ,(--agg_demand
        SELECT 
            sum(b2.buy_qty) AS agg_buy
            ,os.price
        FROM
            order_straddle os
            INNER JOIN order_straddle b2 ON (b2.price>=os.price)
        GROUP BY
            os.price
    ) AS agg_demand
    ,(--agg_supply
        SELECT 
            os.price
            ,sum(s2.sell_qty) AS agg_sell
        FROM
            order_straddle os
            INNER JOIN order_straddle s2 ON (s2.price<=os.price)
        GROUP BY
            os.price
    ) AS agg_supply
WHERE
        agg_demand.price = agg_supply.price
    AND o.price = agg_demand.price
    AND o.price = agg_supply.price
ORDER BY 
    price desc
;


explain analyze select * from agg_straddle order by max_transact desc limit 1;
