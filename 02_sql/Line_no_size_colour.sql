SELECT 
    Transaction_Type,
    COUNT(*) AS total_lines,
    SUM(CASE
        WHEN Size IS NULL OR TRIM(Size) = '' THEN 1
        ELSE 0
    END) AS missing_size,
    SUM(CASE
        WHEN Color IS NULL OR TRIM(Color) = '' THEN 1
        ELSE 0
    END) AS missing_colour
FROM
    work_sales
GROUP BY Transaction_Type;