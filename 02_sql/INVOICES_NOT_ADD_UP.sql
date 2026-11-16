DROP TABLE IF EXISTS work_bad_invoices;
CREATE TABLE work_bad_invoices AS
SELECT Invoice_ID,
       MAX(Invoice_Total) AS inv_total,
       SUM(Line_Total)    AS lines_sum,
       COUNT(*)           AS n_lines,
       MAX(Line)          AS max_line
FROM transactions
GROUP BY Invoice_ID
HAVING ABS(MAX(Invoice_Total) - SUM(Line_Total)) > 0.01;

SELECT ROUND(inv_total / lines_sum, 2)       AS ratio_total_to_lines,
       COUNT(*)                              AS invoices,
       SUM(CASE WHEN n_lines <> max_line THEN 1 ELSE 0 END) AS invoices_with_missing_line_no
FROM work_bad_invoices
GROUP BY 1
ORDER BY invoices DESC
LIMIT 10;

SELECT LEFT(Invoice_ID, 3)        AS invoice_kind,
       SUBSTRING(Invoice_ID, 5, 2) AS country_code,
       COUNT(*)                   AS bad_invoices
FROM work_bad_invoices
GROUP BY 1, 2
ORDER BY bad_invoices DESC;