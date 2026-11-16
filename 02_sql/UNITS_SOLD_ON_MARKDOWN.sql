SELECT 
    Category,
    Sub_Category,
    SUM(Qty_Raw) AS units_sold,
    SUM(CASE
        WHEN Is_Markdown = 1 THEN Qty_Raw
        ELSE 0
    END) AS units_on_markdown,
    ROUND(100 * SUM(CASE
                WHEN Is_Markdown = 1 THEN Qty_Raw
                ELSE 0
            END) / SUM(Qty_Raw),
            1) AS pct_units_on_markdown
FROM
    work_v_sales
WHERE
    Transaction_Type = 'Sale'
GROUP BY Category , Sub_Category
ORDER BY pct_units_on_markdown DESC;