SELECT 
    COUNT(*) AS lines_checked,
    SUM(CASE
        WHEN e.Employee_ID IS NULL THEN 1
        ELSE 0
    END) AS employee_not_found,
    SUM(CASE
        WHEN
            e.Employee_ID IS NOT NULL
                AND e.Store_ID <> ws.Store_ID
        THEN
            1
        ELSE 0
    END) AS other_store_employee
FROM
    work_sales ws
        LEFT JOIN
    employees e ON e.Employee_ID = ws.Employee_ID;
    