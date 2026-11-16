SELECT Category, Sub_Category,
       ROUND(SUM(Net_Sales_USD), 0)                         AS net_sales_usd,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1) AS gross_margin_pct,
       ROUND(SUM(CASE WHEN Transaction_Type = 'Sale' THEN Net_Sales_USD END)
           / SUM(CASE WHEN Transaction_Type = 'Sale' THEN Qty_Raw END), 2) AS avg_price_usd_per_unit,
       ROUND(SUM(CASE WHEN Transaction_Type = 'Sale' THEN Cost_USD END)
           / SUM(CASE WHEN Transaction_Type = 'Sale' THEN Qty_Raw END), 2) AS avg_cost_usd_per_unit,
       ROUND(100 * SUM(CASE WHEN Transaction_Type = 'Sale' AND Is_Markdown = 1 THEN Qty_Raw END)
           / SUM(CASE WHEN Transaction_Type = 'Sale' THEN Qty_Raw END), 1) AS pct_units_on_markdown
FROM work_fact
GROUP BY Category, Sub_Category
ORDER BY gross_margin_pct ASC;