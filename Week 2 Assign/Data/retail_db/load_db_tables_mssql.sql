Use retail_db;

BULK INSERT dbo.categories FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\categories.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.customers FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\customers.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.departments FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\departments.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.order_items FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\order_items.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.orders FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\orders.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;
BULK INSERT dbo.products FROM 'C:\Users\pitsi\Documents\GitHub\20240617-DE-TS-LectureMaterials\SQL\Data\retail_db\data\products.csv' WITH (FORMAT='CSV', ROWTERMINATOR = '0x0a', FIRSTROW=2) ;

GO

-- Update the order_status column to clean the values 

/*
Teacher Found a fix

--for somereason my loading the orders table in isnt correct for the order status column so this is a fix.
UPDATE orders
SET order_status = TRIM(REPLACE(REPLACE(REPLACE(order_status, CHAR(13), ''), CHAR(10), ''), ' ', ''));
GO
*/

UPDATE orders
SET order_status = REPLACE(order_status, CHAR(13), '')
GO