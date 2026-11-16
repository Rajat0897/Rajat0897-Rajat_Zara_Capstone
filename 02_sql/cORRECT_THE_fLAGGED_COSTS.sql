SET SQL_SAFE_UPDATES = 0;
 
UPDATE work_products p
JOIN   work_cost_flags f ON f.Product_ID = p.Product_ID
SET    p.Cost_EUR_Clean = p.Production_Cost / 100;
 
SET SQL_SAFE_UPDATES = 1;
 
-- Check: flagged products now have a normal cost (expect 25 rows, small numbers)
SELECT p.Product_ID, p.Description_EN, p.Production_Cost, p.Cost_EUR_Clean
FROM work_products p
JOIN work_cost_flags f ON f.Product_ID = p.Product_ID
ORDER BY p.Product_ID
LIMIT 10;