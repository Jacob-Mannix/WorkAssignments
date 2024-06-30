

USE AdventureWorks2022



-- Basic Queries
-- 1. Select all products
SELECT * FROM Production.Product;

-- 2. Select all employees and their job titles
SELECT p.FirstName, p.LastName, e.JobTitle
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

-- 3. List all sales orders from a specific customer (e.g., CustomerID = 295)
SELECT * 
FROM Sales.SalesOrderHeader
WHERE CustomerID = 295;

-- 4. Find the total due by each customer
SELECT CustomerID, SUM(TotalDue) AS TotalDue
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY TotalDue DESC;

-- 5. Find all suppliers (vendors) and their contact information
SELECT v.Name, p.FirstName, p.LastName, pp.PhoneNumber, ea.EmailAddress
FROM Purchasing.Vendor v
JOIN Person.Person p ON v.BusinessEntityID = p.BusinessEntityID
JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID;

-- 6. List all product categories and their subcategories
SELECT c.Name AS CategoryName, s.Name AS SubcategoryName
FROM Production.ProductCategory c
JOIN Production.ProductSubcategory s ON c.ProductCategoryID = s.ProductCategoryID;

-- 7. Find all products that have been discontinued
SELECT * 
FROM Production.Product
WHERE DiscontinuedDate IS NOT NULL;

-- 8. Get the total quantity ordered for each product
SELECT p.Name, SUM(od.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalQuantity DESC;

-- 9. List all addresses associated with a specific customer (e.g., CustomerID = 295)
SELECT a.AddressLine1, a.AddressLine2, a.City, a.StateProvinceID, a.PostalCode, at.Name AS AddressType
FROM Person.Address a
JOIN Person.BusinessEntityAddress bea ON a.AddressID = bea.AddressID
JOIN Person.AddressType at ON bea.AddressTypeID = at.AddressTypeID
JOIN Person.CustomerAddress ca ON bea.BusinessEntityID = ca.AddressID
WHERE ca.CustomerID = 295;

-- 10. Find the top 5 products by total quantity sold
SELECT TOP 5 p.Name, SUM(od.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalQuantity DESC;








-- Challenging Queries with Built-in Functions:

-- 1. Get the number of employees hired each year
SELECT YEAR(HireDate) AS HireYear, COUNT(*) AS NumberOfHires
FROM HumanResources.Employee
GROUP BY YEAR(HireDate)
ORDER BY HireYear;

-- 2. Find the average order amount for each product
SELECT p.Name, AVG(od.LineTotal) AS AverageOrderAmount
FROM Sales.SalesOrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY AverageOrderAmount DESC;

-- 3. Determine the month with the highest sales in a specific year (e.g., 2014)
SELECT MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2014
GROUP BY MONTH(OrderDate)
ORDER BY TotalSales DESC;

-- 4. Retrieve products that have a name length greater than the average product name length
SELECT Name, LEN(Name) AS NameLength
FROM Production.Product
WHERE LEN(Name) > (SELECT AVG(LEN(Name)) FROM Production.Product)
ORDER BY NameLength DESC;

-- 5. Get the next day of the week for all order dates in a table
SELECT OrderDate, DATEADD(day, 1, OrderDate) AS NextDay
FROM Sales.SalesOrderHeader;

-- 6. Calculate the age of each employee
SELECT p.FirstName, p.LastName, DATEDIFF(year, p.BirthDate, GETDATE()) AS Age
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

-- 7. Find the most recent sales order for each customer
SELECT CustomerID, MAX(OrderDate) AS MostRecentOrderDate
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

-- 8. Get the total number of orders placed on the last day of each month
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, COUNT(*) AS TotalOrders
FROM Sales.SalesOrderHeader
WHERE DAY(OrderDate) = DAY(EOMONTH(OrderDate))
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- 9. Retrieve the list of products with names that start with vowels
SELECT Name
FROM Production.Product
WHERE LEFT(Name, 1) IN ('A', 'E', 'I', 'O', 'U')
ORDER BY Name;

-- 10. Calculate the percentage of total sales for each salesperson compared to overall sales
SELECT s.SalesPersonID, 
       SUM(soh.TotalDue) AS SalesPersonTotalSales,
       (SUM(soh.TotalDue) / (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader)) * 100 AS SalesPercentage
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson s ON soh.SalesPersonID = s.BusinessEntityID
GROUP BY s.SalesPersonID
ORDER BY SalesPercentage DESC;








-- Basic Queries with Analytics Functions

-- 1. Calculate the row number for all orders in June of 2011 sorted by SalesOrderID
SELECT 
    SalesOrderID, 
    OrderDate, 
    ROW_NUMBER() OVER (ORDER BY SalesOrderID) AS RowNum
FROM 
    Sales.SalesOrderHeader
WHERE 
    OrderDate BETWEEN '2011-06-01' AND '2011-06-30';

-- 2. Compare information for the current sales order to the total amount due for the day the order was placed
SELECT 
    SalesOrderID, 
    OrderDate, 
    TotalDue,
    SUM(TotalDue) OVER (PARTITION BY OrderDate) AS TotalDueForDay
FROM 
    Sales.SalesOrderHeader;

-- 3. Calculate the 3 Day moving average for order totals in SalesOrderHeader table
SELECT 
    SalesOrderID, 
    OrderDate, 
    TotalDue,
    AVG(TotalDue) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg3Day
FROM 
    Sales.SalesOrderHeader;

-- 4. For each product, rank each order by which has the highest quantity of that product ordered
SELECT 
    ProductID, 
    SalesOrderID, 
    OrderQty,
    RANK() OVER (PARTITION BY ProductID ORDER BY OrderQty DESC) AS ProductRank
FROM 
    Sales.SalesOrderDetail;

-- 5. Compare the date an order was placed on to the previous and next time that someone with the same account number placed an order
SELECT 
    SalesOrderID, 
    CustomerID, 
    OrderDate,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
FROM 
    Sales.SalesOrderHeader;








-- Challenging Queries with Analytics Functions

-- 1. Determine the top 5 products with the highest average monthly sales and their growth rate from the previous month.
WITH MonthlySales AS (
    SELECT 
        ProductID, 
        YEAR(OrderDate) AS Year, 
        MONTH(OrderDate) AS Month, 
        SUM(OrderQty) AS MonthlyQty
    FROM 
        Sales.SalesOrderDetail AS sod
    JOIN 
        Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY 
        ProductID, YEAR(OrderDate), MONTH(OrderDate)
), AvgMonthlySales AS (
    SELECT 
        ProductID, 
        AVG(MonthlyQty) AS AvgMonthlyQty,
        LAG(AVG(MonthlyQty)) OVER (PARTITION BY ProductID ORDER BY YEAR(OrderDate), MONTH(OrderDate)) AS PrevMonthQty
    FROM 
        MonthlySales
    GROUP BY 
        ProductID, YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    ProductID, 
    AvgMonthlyQty, 
    (AvgMonthlyQty - PrevMonthQty) / PrevMonthQty * 100 AS GrowthRate
FROM 
    AvgMonthlySales
ORDER BY 
    AvgMonthlyQty DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 2. Identify customers who have increased their monthly spending for three consecutive months.
WITH MonthlySpending AS (
    SELECT 
        CustomerID, 
        YEAR(OrderDate) AS Year, 
        MONTH(OrderDate) AS Month, 
        SUM(TotalDue) AS MonthlyTotal
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        CustomerID, YEAR(OrderDate), MONTH(OrderDate)
), SpendingGrowth AS (
    SELECT 
        CustomerID, 
        MonthlyTotal, 
        LAG(MonthlyTotal, 1) OVER (PARTITION BY CustomerID ORDER BY Year, Month) AS PrevMonth1,
        LAG(MonthlyTotal, 2) OVER (PARTITION BY CustomerID ORDER BY Year, Month) AS PrevMonth2
    FROM 
        MonthlySpending
)
SELECT 
    CustomerID
FROM 
    SpendingGrowth
WHERE 
    MonthlyTotal > PrevMonth1 AND PrevMonth1 > PrevMonth2
GROUP BY 
    CustomerID;

-- 3. Compute the Year-over-Year (YoY) sales growth for each product category.
WITH YearlySales AS (
    SELECT 
        ProductCategoryID,
        YEAR(OrderDate) AS Year,
        SUM(TotalDue) AS YearlyTotal
    FROM 
        Sales.SalesOrderHeader AS soh
    JOIN 
        Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN 
        Production.Product AS p ON sod.ProductID = p.ProductID
    JOIN 
        Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN 
        Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY 
        ProductCategoryID, YEAR(OrderDate)
), YoYGrowth AS (
    SELECT 
        ProductCategoryID,
        Year,
        YearlyTotal,
        LAG(YearlyTotal) OVER (PARTITION BY ProductCategoryID ORDER BY Year) AS PrevYearTotal
    FROM 
        YearlySales
)
SELECT 
    ProductCategoryID,
    Year,
    YearlyTotal,
    (YearlyTotal - PrevYearTotal) / PrevYearTotal * 100 AS YoYGrowth
FROM 
    YoYGrowth
WHERE 
    PrevYearTotal IS NOT NULL;

-- 4. Rank employees based on their total sales, considering only those who made sales in at least three different months.
WITH EmployeeSales AS (
    SELECT 
        SalesPersonID,
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalDue) AS MonthlyTotal
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        SalesPersonID, YEAR(OrderDate), MONTH(OrderDate)
), EmployeeTotalSales AS (
    SELECT 
        SalesPersonID,
        COUNT(DISTINCT CONCAT(YEAR(OrderDate), MONTH(OrderDate))) AS ActiveMonths,
        SUM(MonthlyTotal) AS TotalSales
    FROM 
        EmployeeSales
    GROUP BY 
        SalesPersonID
)
SELECT 
    SalesPersonID,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM 
    EmployeeTotalSales
WHERE 
    ActiveMonths >= 3;

-- 5. Identify the most profitable day of the week over the past year.
WITH DailySales AS (
    SELECT 
        CAST(OrderDate AS DATE) AS OrderDate,
        DATEPART(WEEKDAY, OrderDate) AS WeekDay,
        SUM(TotalDue) AS DailyTotal
    FROM 
        Sales.SalesOrderHeader
    WHERE 
        OrderDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY 
        CAST(OrderDate AS DATE), DATEPART(WEEKDAY, OrderDate)
)
SELECT 
    WeekDay,
    SUM(DailyTotal) AS TotalSales
FROM 
    DailySales
GROUP BY 
    WeekDay
ORDER BY 
    TotalSales DESC;
