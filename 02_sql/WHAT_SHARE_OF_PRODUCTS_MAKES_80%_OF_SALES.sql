WITH ranked AS (
    SELECT Product_ID, Net_Sales_USD,
           ROW_NUMBER() OVER (ORDER BY Net_Sales_USD DESC, Product_ID)  AS pos,
           SUM(Net_Sales_USD) OVER (ORDER BY Net_Sales_USD DESC, Product_ID
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sales,
           SUM(Net_Sales_USD) OVER ()                                    AS total_sales,
           COUNT(*) OVER ()                                              AS products_that_sold
    FROM work_product_sales
)
SELECT pos                                               AS products_needed_for_80pct,
       products_that_sold,
       ROUND(100 * pos / products_that_sold, 1)          AS pct_of_products_that_sold,
       (SELECT COUNT(*) FROM work_products)              AS all_products,
       ROUND(100 * pos / (SELECT COUNT(*) FROM work_products), 1) AS pct_of_all_products,
       ROUND(100 * running_sales / total_sales, 1)       AS pct_of_sales_reached
FROM ranked
WHERE running_sales >= 0.8 * total_sales
ORDER BY pos
LIMIT 1;
 

SELECT t.decile,
       COUNT(*)                                                    AS products,
       ROUND(SUM(t.Net_Sales_USD))                                 AS net_sales_usd,
       ROUND(100 * SUM(t.Net_Sales_USD) / MAX(t.total_sales), 1)   AS pct_of_sales,
       ROUND(100 * SUM(SUM(t.Net_Sales_USD)) OVER (ORDER BY t.decile) / MAX(t.total_sales), 1) AS cumulative_pct
FROM (
    SELECT Net_Sales_USD,
           NTILE(10) OVER (ORDER BY Net_Sales_USD DESC)  AS decile,
           SUM(Net_Sales_USD) OVER ()                    AS total_sales
    FROM work_product_sales
) t
GROUP BY t.decile
ORDER BY t.decile;