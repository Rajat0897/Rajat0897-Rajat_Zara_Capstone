SELECT COUNT(*) AS rows_in_work_sales FROM work_sales;

SELECT Transaction_Type,
       COUNT(*)              AS line_count,
       MIN(Qty_Signed)       AS min_units,
       MAX(Qty_Signed)       AS max_units,
       MIN(Net_Sales_USD)    AS min_sales_usd,
       MAX(Net_Sales_USD)    AS max_sales_usd
FROM work_sales
GROUP BY Transaction_Type;

SELECT Country,
       ROUND(SUM(Net_Sales_USD), 0) AS net_sales_usd
FROM work_sales
GROUP BY Country
ORDER BY net_sales_usd DESC;

SELECT ROUND(100 * AVG(Is_Markdown), 1) AS pct_of_sale_lines_on_markdown
FROM work_sales
WHERE Transaction_Type = 'Sale';