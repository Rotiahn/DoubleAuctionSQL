----------------------
-- Proc name: auc_buyorderlist_validate
-- Proc description: Verify that a relation is valid and complete buy orderlist (any proc which takes a buy order list as an input should accept this buy orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)


----------------------
-- Proc name: auc_sellorderlist_validate
-- Proc description: Verify that a relation is valid and complete sell orderlist (any proc which takes a sell order list as an input should accept this sell orderlist without issues)
-- Proc inputs: relation
-- Proc output: boolean (true/false)


----------------------
-- Proc name auc_create_buyorderlist
-- Proc description: creates an table that meets the criteria of a buyorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_buyorderlist Test 1:  Run validate on name_of_table


----------------------
-- Proc name auc_create_sellorderlist
-- Proc description: creates an table that meets the criteria of a sellorderlist
-- Proc inputs: name_of_table
-- Proc outputs: {}


--Tests:
--auc_create_sellorderlist Test 1:  Run validate on name_of_table
