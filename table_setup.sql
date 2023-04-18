


DROP TABLE IF EXISTS buyer_order_list;

CREATE TABLE buyer_order_list (
     order_id   SERIAL  
    ,buyer_id   INT     NOT NULL
    ,qty        INT     NOT NULL
    ,price      money   NOT NULL

    ,UNIQUE(buyer_id,price)
    )
;


DROP TABLE IF EXISTS seller_order_list;

CREATE TABLE seller_order_list (
     order_id   SERIAL  
    ,seller_id  INT     NOT NULL
    ,qty        INT     NOT NULL
    ,price      money   NOT NULL

    ,UNIQUE(seller_id,price)
    )
;

