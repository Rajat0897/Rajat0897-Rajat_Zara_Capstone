-- Save the flagged products in a new table
CREATE TABLE work_cost_flags AS
WITH ranked AS (
    SELECT Product_ID, Sub_Category, Production_Cost,
           ROW_NUMBER() OVER (PARTITION BY Sub_Category ORDER BY Production_Cost) AS rn,
           COUNT(*)     OVER (PARTITION BY Sub_Category)                          AS cnt
    FROM work_products
),
med AS (
    SELECT Sub_Category, AVG(Production_Cost) AS Median_Cost
    FROM ranked
    WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
    GROUP BY Sub_Category
)
SELECT p.Product_ID, p.Sub_Category, p.Description_EN, p.Production_Cost,
       m.Median_Cost,
       ROUND(p.Production_Cost / m.Median_Cost, 1) AS Ratio_to_Median
FROM work_products p
JOIN med m ON p.Sub_Category = m.Sub_Category
WHERE p.Production_Cost > 10 * m.Median_Cost;

-- How many? 
SELECT COUNT(*) AS products_with_impossible_cost FROM work_cost_flags;

-- See them all
SELECT * FROM work_cost_flags ORDER BY Ratio_to_Median DESC;

-- EVIDENCE: compare each flagged cost with what the product actually
SELECT f.Product_ID, f.Description_EN,
       ROUND(f.Production_Cost * 1.08, 2)       AS cost_usd_as_stored,
       ROUND(f.Production_Cost / 100 * 1.08, 2) AS cost_usd_if_divided_by_100,
       ROUND(AVG(CASE WHEN ws.Transaction_Type = 'Sale' AND ws.Is_Markdown = 0
                      THEN ws.Net_Sales_USD / ws.Qty_Raw END), 2) AS avg_full_price_usd,
       COUNT(ws.Invoice_ID)                     AS lines_sold
FROM work_cost_flags f
LEFT JOIN work_sales ws ON ws.Product_ID = f.Product_ID
GROUP BY f.Product_ID, f.Description_EN, f.Production_Cost
ORDER BY f.Product_ID;
 