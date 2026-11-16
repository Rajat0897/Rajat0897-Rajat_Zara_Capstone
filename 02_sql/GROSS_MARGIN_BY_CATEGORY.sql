SELECT Category,
       ROUND(SUM(Net_Sales_USD), 0)                         AS net_sales_usd,
       ROUND(SUM(Margin_USD), 0)                            AS gross_margin_usd,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1) AS gross_margin_pct
FROM work_fact
GROUP BY Category
ORDER BY gross_margin_pct DESC;