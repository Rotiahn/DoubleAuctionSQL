




CREATE TABLE buyer_order_list (
     order_id   SERIAL  
    ,buyer_id   INT     NOT NULL
    ,qty        INT     NOT NULL
    ,price      money   NOT NULL
)
;


