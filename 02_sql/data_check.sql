SELECT 
    Transaction_Type,
    COUNT(*) AS total_lines,
    SUM(CASE
        WHEN ABS(ABS(Line_Total) - Unit_Price * Quantity * (1 - Discount)) > 0.02 THEN 1
        ELSE 0
    END) AS formula_mismatch,
    SUM(CASE
        WHEN
            (Transaction_Type = 'Sale'
                AND Line_Total < 0)
                OR (Transaction_Type = 'Return'
                AND Line_Total > 0)
        THEN
            1
        ELSE 0
    END) AS wrong_sign
FROM
    transactions
GROUP BY Transaction_Type;