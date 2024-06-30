DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE customers;
DROP TABLE products;
DROP TABLE categories;
DROP TABLE departments;


use retail_db;
GO

-- Exercise 1

/*
Example - to study
*/

-- Step 1: Create the Partition Function
CREATE PARTITION FUNCTION pfOrdersRange (DATETIME)
AS RANGE RIGHT FOR VALUES ('2014-01-01', '2014-02-01', '2014-03-01', '2014-04-01', '2014-05-01', '2014-06-01', '2014-07-01', '2014-08-01', '2014-09-01', '2014-10-01', '2014-11-01', '2014-12-01');
GO

-- Step 2: Create the Partition Scheme
CREATE PARTITION SCHEME psOrdersScheme
AS PARTITION pfOrdersRange
ALL TO ([PRIMARY]);
GO

-- Step 3: Create the Partitioned Table
CREATE TABLE orders_part (
    order_id INT IDENTITY PRIMARY KEY,
    order_date DATETIME NOT NULL,
    order_customer_id INT NOT NULL,
    order_status VARCHAR(45) NOT NULL
)
ON psOrdersScheme(order_date);
GO

-- Step 4: Insert Data into the Partitioned Table (assuming data exists in orders table)
INSERT INTO orders_part (order_date, order_customer_id, order_status)
SELECT order_date, order_customer_id, order_status
FROM orders
WHERE order_date >= '2014-01-01' AND order_date < '2014-02-01';
GO

-- Step 5: Validate the Partition
-- Validate Partition Scheme
SELECT * 
FROM sys.partition_schemes 
WHERE name = 'psOrdersScheme';
GO

-- Validate Partition Function
SELECT * 
FROM sys.partition_functions 
WHERE name = 'pfOrdersRange';
GO


--Exercise 2

/*
example for studying
*/
-- Load data from orders into orders_part
INSERT INTO orders_part (order_date, order_customer_id, order_status)
SELECT order_date, order_customer_id, order_status
FROM orders;
GO


-- Get the total count on orders_part
SELECT COUNT(*) AS total_count
FROM orders_part;
GO

-- Get the count of records in each partition
SELECT 
    $PARTITION.pfOrdersRange(order_date) AS partition_number, 
    COUNT(*) AS partition_count
FROM orders_part
GROUP BY $PARTITION.pfOrdersRange(order_date);
GO
