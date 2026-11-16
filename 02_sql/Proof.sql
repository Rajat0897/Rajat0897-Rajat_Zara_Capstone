SELECT 'stores' AS table_name, COUNT(*) AS row_count FROM stores
UNION ALL SELECT 'employees',    COUNT(*) FROM employees
UNION ALL SELECT 'customers',    COUNT(*) FROM customers
UNION ALL SELECT 'products',     COUNT(*) FROM products
UNION ALL SELECT 'discounts',    COUNT(*) FROM discounts
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;