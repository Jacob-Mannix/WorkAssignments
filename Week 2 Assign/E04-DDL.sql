





USE retail_db;
GO


-- Exercise 1
-- Get maximum value for departments table
SELECT MAX(department_id) AS max_department_id FROM departments;
GO

-- Get maximum value for categories table
SELECT MAX(category_id) AS max_category_id FROM categories;
GO

-- Get maximum value for products table
SELECT MAX(product_id) AS max_product_id FROM products;
GO

-- Get maximum value for customers table
SELECT MAX(customer_id) AS max_customer_id FROM customers;
GO

-- Get maximum value for orders table
SELECT MAX(order_id) AS max_order_id FROM orders;
GO

-- Get maximum value for order_items table
SELECT MAX(order_item_id) AS max_order_item_id FROM order_items;
GO


-- Adjusting the starting value for departments table
CREATE TABLE departments (
  department_id INT IDENTITY(6, 1) NOT NULL,
  department_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (department_id)
);

-- Adjusting the starting value for categories table
CREATE TABLE categories (
  category_id INT IDENTITY(11, 1) NOT NULL,
  category_department_id INT NOT NULL,
  category_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (category_id)
);

-- Adjusting the starting value for products table
CREATE TABLE products (
  product_id INT IDENTITY(51, 1) NOT NULL,
  product_category_id INT NOT NULL,
  product_name VARCHAR(45) NOT NULL,
  product_description VARCHAR(255) NOT NULL,
  product_price FLOAT NOT NULL,
  product_image VARCHAR(255) NOT NULL,
  PRIMARY KEY (product_id)
);

-- Adjusting the starting value for customers table
CREATE TABLE customers (
  customer_id INT IDENTITY(101, 1) NOT NULL,
  customer_fname VARCHAR(45) NOT NULL,
  customer_lname VARCHAR(45) NOT NULL,
  customer_email VARCHAR(45) NOT NULL,
  customer_password VARCHAR(45) NOT NULL,
  customer_street VARCHAR(255) NOT NULL,
  customer_city VARCHAR(45) NOT NULL,
  customer_state VARCHAR(45) NOT NULL,
  customer_zipcode VARCHAR(45) NOT NULL,
  PRIMARY KEY (customer_id)
);

-- Adjusting the starting value for orders table
CREATE TABLE orders (
  order_id INT IDENTITY(201, 1) NOT NULL,
  order_date DATETIME NOT NULL,
  order_customer_id INT NOT NULL,
  order_status VARCHAR(45) NOT NULL,
  PRIMARY KEY (order_id)
);

-- Adjusting the starting value for order_items table
CREATE TABLE order_items (
  order_item_id INT IDENTITY(501, 1) NOT NULL,
  order_item_order_id INT NOT NULL,
  order_item_product_id INT NOT NULL,
  order_item_quantity INT NOT NULL,
  order_item_subtotal FLOAT NOT NULL,
  order_item_product_price FLOAT NOT NULL,
  PRIMARY KEY (order_item_id)
);


-- Exercise 2
-- Check for orders.order_customer_id not in customers.customer_id
SELECT o.order_id, o.order_customer_id
FROM orders o
LEFT JOIN customers c ON o.order_customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check for order_items.order_item_order_id not in orders.order_id
SELECT oi.order_item_id, oi.order_item_order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_item_order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for order_items.order_item_product_id not in products.product_id
SELECT oi.order_item_id, oi.order_item_product_id
FROM order_items oi
LEFT JOIN products p ON oi.order_item_product_id = p.product_id
WHERE p.product_id IS NULL;

-- Check for products.product_category_id not in categories.category_id
SELECT p.product_id, p.product_category_id
FROM products p
LEFT JOIN categories c ON p.product_category_id = c.category_id
WHERE c.category_id IS NULL;

-- Check for categories.category_department_id not in departments.department_id
SELECT c.category_id, c.category_department_id
FROM categories c
LEFT JOIN departments d ON c.category_department_id = d.department_id
WHERE d.department_id IS NULL;


-- Add foreign key to orders.order_customer_id
ALTER TABLE orders
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id);

-- Add foreign key to order_items.order_item_order_id
ALTER TABLE order_items
ADD CONSTRAINT FK_order_items_orders
FOREIGN KEY (order_item_order_id) REFERENCES orders(order_id);

-- Add foreign key to order_items.order_item_product_id
ALTER TABLE order_items
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (order_item_product_id) REFERENCES products(product_id);

-- Add foreign key to products.product_category_id
ALTER TABLE products
ADD CONSTRAINT FK_products_categories
FOREIGN KEY (product_category_id) REFERENCES categories(category_id);

-- Add foreign key to categories.category_department_id
ALTER TABLE categories
ADD CONSTRAINT FK_categories_departments
FOREIGN KEY (category_department_id) REFERENCES departments(department_id);



-- Set order_customer_id to NULL where it violates foreign key constraint
UPDATE orders
SET order_customer_id = NULL
WHERE order_customer_id NOT IN (SELECT customer_id FROM customers);

-- Set order_item_order_id to NULL where it violates foreign key constraint
UPDATE order_items
SET order_item_order_id = NULL
WHERE order_item_order_id NOT IN (SELECT order_id FROM orders);

-- Set order_item_product_id to NULL where it violates foreign key constraint
UPDATE order_items
SET order_item_product_id = NULL
WHERE order_item_product_id NOT IN (SELECT product_id FROM products);

-- Set product_category_id to NULL where it violates foreign key constraint
UPDATE products
SET product_category_id = NULL
WHERE product_category_id NOT IN (SELECT category_id FROM categories);

-- Set category_department_id to NULL where it violates foreign key constraint
UPDATE categories
SET category_department_id = NULL
WHERE category_department_id NOT IN (SELECT department_id FROM departments);


-- exercise 3

--checking primary keys
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    CONSTRAINT_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    CONSTRAINT_NAME LIKE 'PK_%';
GO



--checking foeign keys
SELECT 
    CONSTRAINT_NAME, 
    TABLE_NAME, 
    COLUMN_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
ON 
    RC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
JOIN 
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU
ON 
    RC.UNIQUE_CONSTRAINT_NAME = CCU.CONSTRAINT_NAME;
GO



-- checking all constraints in a specific table - example
SELECT 
    TABLE_NAME, 
    CONSTRAINT_NAME, 
    CONSTRAINT_TYPE
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE 
    TABLE_NAME = 'orders';

