# DoubleAuctionSQL
A postgreSQL library with the aim of providing a set of tools for managing Double Auctions in a database.

---

### Files:
* **procs.sql** - The core of the library.  All operations can be done by functions/procedures within this file.
* **table_setup.sql** - An example script showing how to generate the tables necessary to run an auction.
* **order_generator.sql** - A collection of queries to randomly generate a list of buy & sell orders to run an auction.
* **auctioneer.sql** - Examples use case.

---
Note: DoubleAuctionSQL is tested in PostgreSQL 15.  The procs.sql file is PostgreSQL specific and may not work on earlier versions of PostgreSQL or on other RDMS.
---

### Installation:
```sh
cd Extension
cp *.sql *.control /usr/share/postgresql/15/extension/
```

### Enable Database:
```sql
CREATE EXTENSION "DoubleAuctionSQL";
```

