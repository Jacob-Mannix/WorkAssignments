




USE retail_db
GO


-- Exercise 1
-- Retrieve the names of categories that have more than 5 products
SELECT category_name
FROM categories
WHERE category_id IN (
    SELECT product_category_id
    FROM products
    GROUP BY product_category_id
    HAVING COUNT(product_id) > 5
);


-- Exercise 2
SELECT *
FROM orders
WHERE order_customer_id IN (
	SELECT order_customer_id
	FROM orders
	GROUP BY order_customer_id
	HAVING COUNT(order_id) > 10
);



-- Exercise 3
-- Display the product names along with the average price of all products that were ordered in October 2013
SELECT 
    p.product_name,
    (SELECT 
		AVG(order_item_product_price)
     FROM 
		order_items oi
     JOIN orders o ON oi.order_item_order_id = o.order_id
     WHERE 
		o.order_date BETWEEN '2013-10-01' AND '2013-10-31'
       AND 
		oi.order_item_product_id = p.product_id
	) AS average_price
FROM 
    products p;




-- Exercise 4


-- List the orders that have a total amount greater than the average order amount
SELECT 
	o.order_id,
	o.order_date, 
	o.order_customer_id, 
	o.order_status, 
	SUM(oi.order_item_subtotal) AS order_total
FROM 
	orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
GROUP BY 
	o.order_id, o.order_date, o.order_customer_id, o.order_status
HAVING SUM(oi.order_item_subtotal) > (SELECT AVG(order_total) FROM (
                                        SELECT SUM(order_item_subtotal) AS order_total
                                        FROM order_items
                                        GROUP BY order_item_order_id
                                      ) AS avg_order_totals);
GO


-- Exercise 5
-- Use a CTE to find the top 3 categories based on the number of products
WITH CategoryProductCounts AS (
    SELECT 
        p.product_category_id, 
        COUNT(p.product_id) AS product_count
    FROM 
        products p
    GROUP BY 
        p.product_category_id
)
SELECT TOP 3 
    c.category_name, 
    cpc.product_count
FROM 
    CategoryProductCounts cpc
JOIN 
    categories c ON c.category_id = cpc.product_category_id
ORDER BY 
    cpc.product_count DESC;





-- Exercise 6
-- study this ***********************************************************************************************************
-- Identify the customers who have spent more than the average spending of customers in the month of December
WITH CustomerSpending AS (
    SELECT 
		o.order_customer_id, 
		SUM(oi.order_item_subtotal) AS total_spending
    FROM 
		orders o
    JOIN 
		order_items oi ON o.order_id = oi.order_item_order_id
    WHERE 
		o.order_date BETWEEN '2013-12-01' AND '2013-12-31'
    GROUP BY 
		o.order_customer_id
),
AverageSpending AS (
    SELECT AVG(total_spending) AS avg_spending
    FROM CustomerSpending
)
SELECT 
	cs.order_customer_id, cs.total_spending
FROM 
	CustomerSpending cs
JOIN AverageSpending avg ON cs.total_spending > avg.avg_spending;
