

USE hr_db;
GO


-- Exercise 1
-- Get all employees who are making more than the average salary within each department
SELECT 
    e.employee_id, 
    d.department_name, 
    e.salary, 
    ROUND(avg_salaries.avg_salary, 2) AS avg_salary_expense
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    (
        SELECT 
            department_id, 
            AVG(salary) AS avg_salary
        FROM 
            employees
        GROUP BY 
            department_id
    ) avg_salaries ON e.department_id = avg_salaries.department_id
WHERE 
    e.salary > avg_salaries.avg_salary
ORDER BY 
    e.department_id ASC, 
    e.salary DESC;
GO


-- Exercise 2
-- Get cumulative salary within each department for Finance and IT departments along with department name
SELECT 
    e.employee_id, 
    d.department_name, 
    e.salary, 
    ROUND(SUM(e.salary) OVER (PARTITION BY e.department_id ORDER BY e.salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cum_salary_expense
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    d.department_name IN ('Finance', 'IT')
ORDER BY 
    d.department_name ASC, 
    e.salary ASC;
GO


-- Exercise 3
-- Get top 3 paid employees within each department by salary using dense_rank
WITH RankedEmployees AS (
    SELECT 
        e.employee_id, 
        e.department_id, 
        d.department_name, 
        e.salary, 
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS employee_rank
    FROM 
        employees e
    JOIN 
        departments d ON e.department_id = d.department_id
)
SELECT 
    employee_id, 
    department_id, 
    department_name, 
    salary, 
    employee_rank
FROM 
    RankedEmployees
WHERE 
    employee_rank <= 3
ORDER BY 
    department_id ASC, 
    salary DESC;
GO



-- Exercise 4
-- Get top 3 products sold in the month of January 2014 by revenue

USE retail_db;
GO

WITH ProductRevenue AS (
    SELECT 
        p.product_id, 
        p.product_name, 
        ROUND(SUM(oi.order_item_subtotal), 2) AS revenue,
        DENSE_RANK() OVER (ORDER BY SUM(oi.order_item_subtotal) DESC) AS product_rank
    FROM 
        orders o
    JOIN 
        order_items oi ON o.order_id = oi.order_item_order_id
    JOIN 
        products p ON oi.order_item_product_id = p.product_id
    WHERE 
        FORMAT(o.order_date, 'yyyy-MM') = '2014-01'
        AND o.order_status IN ('COMPLETE', 'CLOSED')
    GROUP BY 
        p.product_id, 
        p.product_name
)
SELECT 
    product_id, 
    product_name, 
    revenue, 
    product_rank
FROM 
    ProductRevenue
WHERE 
    product_rank <= 3
ORDER BY 
    revenue DESC;




-- Exercise 5
-- Define the CTE to calculate revenue and rank products by revenue within each category
WITH RankedProducts AS (
    SELECT
        c.category_id,
        c.category_name,
        p.product_id,
        p.product_name,
        SUM(oi.order_item_subtotal) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY c.category_id 
            ORDER BY SUM(oi.order_item_subtotal) DESC
        ) AS product_rank
    FROM
        orders o
    JOIN order_items oi ON o.order_id = oi.order_item_order_id
    JOIN products p ON oi.order_item_product_id = p.product_id
    JOIN categories c ON p.product_category_id = c.category_id
    WHERE
        o.order_status IN ('COMPLETE', 'CLOSED')
        AND o.order_date BETWEEN '2014-01-01' AND '2014-01-31'
        AND c.category_name IN ('Cardio Equipment', 'Strength Training')
    GROUP BY
        c.category_id,
        c.category_name,
        p.product_id,
        p.product_name
)
-- Select top 3 products for each category from the CTE
SELECT
    category_id,
    category_name,
    product_id,
    product_name,
    revenue,
    product_rank
FROM
    RankedProducts
WHERE
    product_rank <= 3
ORDER BY
    category_id,
    product_rank;
GO
