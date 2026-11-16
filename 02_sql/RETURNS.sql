SELECT 'Full price' AS sold_at,
       SUM(Units_Sold - Units_Sold_MD)         AS units_sold,
       SUM(Units_Returned - Units_Returned_MD) AS units_returned,
       ROUND(100 * SUM(Units_Returned - Units_Returned_MD) / SUM(Units_Sold - Units_Sold_MD), 2) AS return_rate_pct
FROM work_daily
UNION ALL
SELECT 'Markdown',
       SUM(Units_Sold_MD), SUM(Units_Returned_MD),
       ROUND(100 * SUM(Units_Returned_MD) / SUM(Units_Sold_MD), 2)
FROM work_daily;
 
SELECT Country,
       SUM(Units_Sold)     AS units_sold,
       SUM(Units_Returned) AS units_returned,
       ROUND(100 * SUM(Units_Returned) / SUM(Units_Sold), 2) AS return_rate_pct
FROM work_daily
GROUP BY Country
ORDER BY return_rate_pct DESC;
 
SELECT Category, Sub_Category,
       SUM(Units_Sold)     AS units_sold,
       SUM(Units_Returned) AS units_returned,
       ROUND(100 * SUM(Units_Returned) / SUM(Units_Sold), 2) AS return_rate_pct
FROM work_daily
GROUP BY Category, Sub_Category
ORDER BY return_rate_pct DESC;
 
-- 13.4  By size [SLOW: reads all rows once]. Size labels differ by category
--       (letters for clothes, numbers for jeans and shoes, ages for kids),
--       so read this together with 13.3. Only sizes with 5,000+ units sold.
SELECT IFNULL(NULLIF(TRIM(Size), ''), 'Unknown') AS size_label,
       SUM(CASE WHEN Transaction_Type = 'Sale'   THEN Qty_Raw ELSE 0 END) AS units_sold,
       SUM(CASE WHEN Transaction_Type = 'Return' THEN Qty_Raw ELSE 0 END) AS units_returned,
       ROUND(100 * SUM(CASE WHEN Transaction_Type = 'Return' THEN Qty_Raw ELSE 0 END)
                 / SUM(CASE WHEN Transaction_Type = 'Sale'   THEN Qty_Raw ELSE 0 END), 2) AS return_rate_pct
FROM work_fact
GROUP BY 1
HAVING units_sold >= 5000
ORDER BY return_rate_pct DESC;
 
-- 13.5  Outlier PRODUCTS. A product is flagged when its return rate is far
--       above its own sub-category's rate. "z_score" says how many standard
--       errors above the sub-category average it is (4+ = very unlikely to
--       be chance). Only products with 100+ units sold, so tiny samples
--       cannot fool us.
DROP TABLE IF EXISTS work_return_outliers;
CREATE TABLE work_return_outliers AS
WITH prod AS (
    SELECT ps.Product_ID, p.Category, p.Sub_Category, p.Description_EN, p.Color,
           ps.Units_Sold, ps.Units_Returned,
           ps.Units_Returned / ps.Units_Sold AS rr
    FROM work_product_sales ps
    JOIN work_products p ON p.Product_ID = ps.Product_ID
    WHERE ps.Units_Sold >= 100
),
sub AS (
    SELECT p.Category, p.Sub_Category,
           SUM(ps.Units_Returned) / SUM(ps.Units_Sold) AS sub_rr
    FROM work_product_sales ps
    JOIN work_products p ON p.Product_ID = ps.Product_ID
    GROUP BY p.Category, p.Sub_Category
)
SELECT prod.Product_ID, prod.Category, prod.Sub_Category, prod.Description_EN, prod.Color,
       prod.Units_Sold, prod.Units_Returned,
       ROUND(100 * prod.rr, 1)          AS return_rate_pct,
       ROUND(100 * sub.sub_rr, 1)       AS subcat_rate_pct,
       ROUND(prod.rr / sub.sub_rr, 1)   AS times_subcat_rate,
       ROUND((prod.rr - sub.sub_rr) / SQRT(sub.sub_rr * (1 - sub.sub_rr) / prod.Units_Sold), 1) AS z_score
FROM prod
JOIN sub ON sub.Category = prod.Category AND sub.Sub_Category = prod.Sub_Category
WHERE (prod.rr - sub.sub_rr) / SQRT(sub.sub_rr * (1 - sub.sub_rr) / prod.Units_Sold) >= 4;
 
-- 13.5a  How many outliers, and the worst 15                  [PASTE]
SELECT COUNT(*) AS outlier_products FROM work_return_outliers;
SELECT * FROM work_return_outliers ORDER BY z_score DESC LIMIT 15;
 
-- 13.6  What might be wrong? For the 8 worst outliers, is the problem in
--       ONE size (a sizing/pattern fault) or in all sizes (quality/photo)?  [PASTE]
SELECT o.Product_ID, o.Description_EN, o.Color,
       IFNULL(NULLIF(TRIM(f.Size), ''), 'Unknown') AS size_label,
       SUM(CASE WHEN f.Transaction_Type = 'Sale'   THEN f.Qty_Raw ELSE 0 END) AS units_sold,
       SUM(CASE WHEN f.Transaction_Type = 'Return' THEN f.Qty_Raw ELSE 0 END) AS units_returned,
       ROUND(100 * SUM(CASE WHEN f.Transaction_Type = 'Return' THEN f.Qty_Raw ELSE 0 END)
                 / NULLIF(SUM(CASE WHEN f.Transaction_Type = 'Sale' THEN f.Qty_Raw ELSE 0 END), 0), 1) AS return_rate_pct
FROM (SELECT Product_ID, Description_EN, Color
      FROM work_return_outliers ORDER BY z_score DESC LIMIT 8) o
JOIN work_fact f ON f.Product_ID = o.Product_ID
GROUP BY 1, 2, 3, 4
ORDER BY o.Product_ID, return_rate_pct DESC;