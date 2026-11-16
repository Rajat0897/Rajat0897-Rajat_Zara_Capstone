SELECT 
    COUNT(*) AS invoices_checked,
    SUM(CASE
        WHEN ABS(inv_total - lines_sum) > 0.01 THEN 1
        ELSE 0
    END) AS invoices_mismatched
FROM
    (SELECT 
        Invoice_ID,
            MAX(Invoice_Total) AS inv_total,
            SUM(Line_Total) AS lines_sum
    FROM
        transactions
    GROUP BY Invoice_ID) x;
    
   SELECT 
    Invoice_ID,
    inv_total,
    lines_sum,
    ROUND(inv_total - lines_sum, 2) AS gap
FROM
    (SELECT 
        Invoice_ID,
            MAX(Invoice_Total) AS inv_total,
            SUM(Line_Total) AS lines_sum
    FROM
        transactions
    GROUP BY Invoice_ID) x
WHERE
    ABS(inv_total - lines_sum) > 0.01
ORDER BY ABS(inv_total - lines_sum) DESC
LIMIT 15;