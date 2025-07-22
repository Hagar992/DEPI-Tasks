USE AdventureWorks2022;
GO

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME;



SELECT 
    t.name AS Table_Name,
    c.name AS Column_Name,
    ty.name AS Data_Type,
    c.max_length,
    c.is_nullable,
    c.is_identity
FROM 
    sys.tables AS t
INNER JOIN 
    sys.columns AS c ON t.object_id = c.object_id
INNER JOIN 
    sys.types AS ty ON c.user_type_id = ty.user_type_id
ORDER BY 
    t.name, c.column_id;

 --  __________________________________________________
 -- 1.1 List all employees hired after January 1, 2012, showing their ID, first name, last name, and hire date, ordered by hire date descending.
 SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.HireDate
FROM 
    HumanResources.Employee AS e
INNER JOIN 
    Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE 
    e.HireDate > '2012-01-01'
ORDER BY 
    e.HireDate DESC;



-- 1.2 Products with list price between $100 and $500
SELECT ProductID, Name, ListPrice, ProductNumber
FROM Production.Product
WHERE ListPrice BETWEEN 100 AND 500
ORDER BY ListPrice ASC;

-- 1.3 Customers from Seattle or Portland
SELECT c.CustomerID, p.FirstName, p.LastName, a.City
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.CustomerAddress ca ON ca.CustomerID = c.CustomerID
JOIN Person.Address a ON ca.AddressID = a.AddressID
WHERE a.City IN ('Seattle', 'Portland');

-- 1.4 Top 15 most expensive products being sold
SELECT TOP 15 p.Name, p.ListPrice, p.ProductNumber, pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL
ORDER BY p.ListPrice DESC;

-- 2.1 Products with name containing 'Mountain' and color is 'Black'
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '%Mountain%' AND Color = 'Black';

-- 2.2 Employees born between 1970 and 1985
SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    e.BirthDate,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate BETWEEN '1970-01-01' AND '1985-12-31';

-- 2.3 Orders placed in Q4 2013
SELECT SalesOrderID, OrderDate, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) IN (10, 11, 12);

-- 2.4 Products with NULL weight and NOT NULL size
SELECT ProductID, Name, Weight, Size, ProductNumber
FROM Production.Product
WHERE Weight IS NULL AND Size IS NOT NULL;

-- 3.1 Count of products by category
SELECT pc.Name AS CategoryName, COUNT(*) AS ProductCount
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY ProductCount DESC;

-- 3.2 Average list price by subcategory with more than 5 products
SELECT ps.Name AS SubcategoryName, AVG(p.ListPrice) AS AveragePrice
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.Name
HAVING COUNT(*) > 5;

-- 3.3 Top 10 customers by order count
SELECT TOP 10 c.CustomerID, p.FirstName + ' ' + p.LastName AS CustomerName, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader s
JOIN Sales.Customer c ON s.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

-- 3.4 Monthly sales totals for 2013
SELECT DATENAME(MONTH, OrderDate) AS MonthName, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

-- 4.1 Products launched same year as 'Mountain-100 Black, 42'
DECLARE @launchYear INT = (
    SELECT YEAR(SellStartDate)
    FROM Production.Product
    WHERE Name = 'Mountain-100 Black, 42'
);
SELECT ProductID, Name, SellStartDate, YEAR(SellStartDate) AS LaunchYear
FROM Production.Product
WHERE YEAR(SellStartDate) = @launchYear;

-- 4.2 Employees hired on same date as someone else
SELECT 
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.HireDate,
    COUNT(*) OVER (PARTITION BY e.HireDate) AS HireDateCount
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate IN (
    SELECT HireDate
    FROM HumanResources.Employee
    GROUP BY HireDate
    HAVING COUNT(*) > 1
);

-- 5.1 Create Sales.ProductReviews table
CREATE TABLE Sales.ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATE DEFAULT GETDATE(),
    ReviewText NVARCHAR(1000),
    VerifiedPurchase BIT DEFAULT 0,
    HelpfulVotes INT DEFAULT 0 CHECK (HelpfulVotes >= 0),
    CONSTRAINT FK_ProductReviews_Product FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
    CONSTRAINT FK_ProductReviews_Customer FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID),
    CONSTRAINT UQ_Product_Customer UNIQUE (ProductID, CustomerID)
);

-- 6.1 Add LastModifiedDate column
ALTER TABLE Production.Product
ADD LastModifiedDate DATETIME DEFAULT GETDATE();

-- 6.2 Create non-clustered index
CREATE NONCLUSTERED INDEX IX_Person_LastName
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);

-- 6.3 Add check constraint on ListPrice > StandardCost
ALTER TABLE Production.Product
ADD CONSTRAINT CHK_ListPrice_GT_StandardCost CHECK (ListPrice > StandardCost);

-- 7.1 Insert sample reviews
INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchase, HelpfulVotes)
VALUES 
(1, 11000, 5, 'Excellent product, highly recommend!', 1, 10),
(2, 11001, 3, 'Decent, but has some issues.', 0, 2),
(3, 11002, 4, 'Great value for money.', 1, 5);

-- 7.2 Insert new category and subcategory
INSERT INTO Production.ProductCategory (Name)
VALUES ('Electronics');

DECLARE @CategoryID INT = SCOPE_IDENTITY();

INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name)
VALUES (@CategoryID, 'Smartphones');

-- 7.3 Copy discontinued products
SELECT *
INTO Sales.DiscontinuedProducts
FROM Production.Product
WHERE SellEndDate IS NOT NULL;

-- 8.1 Update ModifiedDate for expensive products
UPDATE Production.Product
SET ModifiedDate = GETDATE()
WHERE ListPrice > 1000 AND SellEndDate IS NULL;

-- 8.2 Increase ListPrice for Bikes
UPDATE p
SET p.ListPrice = p.ListPrice * 1.15,
    p.ModifiedDate = GETDATE()
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';

-- 8.3 Prefix JobTitle for older hires
UPDATE HumanResources.Employee
SET JobTitle = 'Senior ' + JobTitle
WHERE HireDate < '2010-01-01';

-- 9.1 Delete low-rating unhelpful reviews
DELETE FROM Sales.ProductReviews
WHERE Rating = 1 AND HelpfulVotes = 0;

-- 9.2 Delete never-ordered products
DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail sod
    WHERE sod.ProductID = Production.Product.ProductID
);

-- 9.3 Delete POs from inactive vendors
DELETE FROM Purchasing.PurchaseOrderHeader
WHERE VendorID IN (
    SELECT VendorID FROM Purchasing.Vendor WHERE ActiveFlag = 0
);

-- 10.1 Total sales by year
SELECT 
    YEAR(OrderDate) AS Year,
    SUM(TotalDue) AS TotalSales,
    AVG(TotalDue) AS AvgOrderValue,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(OrderDate)
ORDER BY Year;

-- 10.2 Customer sales summary
SELECT 
    CustomerID,
    COUNT(SalesOrderID) AS TotalOrders,
    SUM(TotalDue) AS TotalAmount,
    AVG(TotalDue) AS AvgOrderValue,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

-- 10.3 Top 20 products by sales
SELECT TOP 20
    p.Name AS ProductName,
    c.Name AS Category,
    SUM(sod.OrderQty) AS TotalQuantitySold,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY p.Name, c.Name
ORDER BY TotalRevenue DESC;

-- 10.4 Sales by month for 2013
WITH MonthlySales AS (
    SELECT 
        DATENAME(MONTH, OrderDate) AS MonthName,
        MONTH(OrderDate) AS MonthNum,
        SUM(TotalDue) AS SalesAmount
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
)
SELECT 
    MonthName,
    SalesAmount,
    CAST(SalesAmount * 100.0 / SUM(SalesAmount) OVER () AS DECIMAL(5,2)) AS PercentOfYear
FROM MonthlySales
ORDER BY MonthNum;



-- 11.1 Employees with full name, age, years of service, formatted hire date, birth month name
SELECT 
    p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS FullName,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS AgeInYears,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
    FORMAT(e.HireDate, 'MMM dd, yyyy') AS FormattedHireDate,
    DATENAME(MONTH, e.BirthDate) AS BirthMonth
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

-- 11.2 Format customer names, extract email domain, proper case
SELECT 
    UPPER(p.LastName) + ', ' + LEFT(p.FirstName,1) + LOWER(SUBSTRING(p.FirstName,2,LEN(p.FirstName))) + ' ' +
    LEFT(p.MiddleName,1) + '.' AS FormattedName,
    RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) AS EmailDomain
FROM Person.Person p
JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID;

-- 11.3 Products with weight and price per pound
SELECT 
    Name,
    ROUND(Weight, 1) AS RoundedWeight,
    ROUND(Weight / 453.59237, 2) AS WeightInPounds,
    CASE WHEN Weight IS NOT NULL AND Weight > 0 THEN ListPrice / (Weight / 453.59237) ELSE NULL END AS PricePerPound
FROM Production.Product;


-- 12.1
SELECT D.Name AS DepartmentName, COUNT(E.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Department D
LEFT JOIN HumanResources.EmployeeDepartmentHistory EDH
    ON D.DepartmentID = EDH.DepartmentID AND EDH.EndDate IS NULL
LEFT JOIN HumanResources.Employee E
    ON EDH.BusinessEntityID = E.BusinessEntityID


 -- 12.2


SELECT BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY BusinessEntityID
HAVING COUNT(DISTINCT DepartmentID) > 1;


-- 13.1

SELECT TOP 5 FirstName, LastName, HireDate
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
ORDER BY HireDate DESC;


 -- 13.2
SELECT FirstName, LastName, HireDate
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
WHERE DATEDIFF(YEAR, HireDate, GETDATE()) > 10;


--14.1


SELECT DISTINCT JobTitle
FROM HumanResources.Employee;


--14.2**

SELECT TOP 1 FirstName, LastName, HireDate
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
ORDER BY HireDate ASC;


--15.1**


SELECT E.BusinessEntityID, FirstName, LastName, D.Name AS Department
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL;


---15.2
SELECT BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY BusinessEntityID
HAVING COUNT(DISTINCT DepartmentID) > 1;


-- 16.1
SELECT E.BusinessEntityID, FirstName, LastName, E.JobTitle, D.Name AS Department
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D ON EDH.DepartmentID = D.DepartmentID


--16.2
SELECT ManagerID, COUNT(*) AS NumberOfEmployees
FROM HumanResources.Employee
WHERE ManagerID IS NOT NULL
GROUP BY ManagerID;


--17.1


SELECT AVG(DATEDIFF(YEAR, HireDate, GETDATE())) AS AvgYearsWorked
FROM HumanResources.Employee;


--17.2**


SELECT TOP 1 D.Name AS Department, COUNT(*) AS EmployeeCount
FROM HumanResources.EmployeeDepartmentHistory EDH
JOIN HumanResources.Department D ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL
GROUP BY D.Name
ORDER BY EmployeeCount DESC;


--18.1**


SELECT FirstName, LastName, HireDate
FROM HumanResources.Employee E
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
WHERE YEAR(HireDate) = (
    SELECT YEAR(HireDate)
    FROM HumanResources.Employee E2
    JOIN Person.Person P2 ON E2.BusinessEntityID = P2.BusinessEntityID
    WHERE P2.FirstName = 'Syed' AND P2.LastName = 'Abbas'
);


--18.2
SELECT
    p.Name AS Product,
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) AS Sales_2013,
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) AS Sales_2014,
    CASE 
        WHEN SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) = 0 THEN NULL
        ELSE 
            ROUND(
                (SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) - 
                 SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)) 
                / 
                 SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) * 100.0, 
                2
            )
    END AS Growth_Percentage,
    CASE 
        WHEN 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) > 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
            THEN 'Increase'
        WHEN 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) < 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
            THEN 'Decrease'
        ELSE 'No Change'
    END AS Growth_Category
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE 
    YEAR(soh.OrderDate) IN (2013, 2014)
GROUP BY 
    p.Name
ORDER BY 
    p.Name;


    -- 19.1 Rank products by sales within each category
SELECT
    pc.Name AS Category,
    p.Name AS Product,
    SUM(sod.LineTotal) AS SalesAmount,
    RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS Rank,
    DENSE_RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS DenseRank,
    ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS RowNumber
FROM
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY
    pc.Name, p.Name;

-- 19.2 Running total of sales by month for 2013
SELECT
    FORMAT(OrderDate, 'yyyy-MM') AS Month,
    SUM(LineTotal) AS MonthlySales,
    SUM(SUM(LineTotal)) OVER (ORDER BY FORMAT(OrderDate, 'yyyy-MM')) AS RunningTotal,
    ROUND(
        SUM(SUM(LineTotal)) OVER (ORDER BY FORMAT(OrderDate, 'yyyy-MM')) * 1.0 /
        SUM(SUM(LineTotal)) OVER (), 2) * 100 AS PercentYTD
FROM
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE
    YEAR(OrderDate) = 2013
GROUP BY
    FORMAT(OrderDate, 'yyyy-MM');

-- 19.3 Three-month moving average of sales per territory
WITH MonthlySales AS (
    SELECT
        st.Name AS Territory,
        FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth,
        SUM(LineTotal) AS Sales
    FROM
        Sales.SalesOrderHeader soh
        JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    WHERE YEAR(OrderDate) = 2013
    GROUP BY st.Name, FORMAT(OrderDate, 'yyyy-MM')
)
SELECT
    Territory,
    SalesMonth,
    Sales,
    ROUND(
        AVG(Sales) OVER (PARTITION BY Territory ORDER BY SalesMonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
    ) AS MovingAverage
FROM MonthlySales;

-- 19.4 Month-over-month sales growth
WITH Monthly AS (
    SELECT
        FORMAT(OrderDate, 'yyyy-MM') AS Month,
        SUM(LineTotal) AS Sales
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(OrderDate) = 2013
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT
    Month,
    Sales,
    LAG(Sales, 1) OVER (ORDER BY Month) AS PreviousMonthSales,
    Sales - LAG(Sales, 1) OVER (ORDER BY Month) AS GrowthAmount,
    ROUND((Sales - LAG(Sales, 1) OVER (ORDER BY Month)) * 100.0 / NULLIF(LAG(Sales, 1) OVER (ORDER BY Month), 0), 2) AS GrowthPercent
FROM Monthly;

-- 19.5 Customers in quartiles by total purchase amount
WITH CustomerTotals AS (
    SELECT
        c.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        SUM(soh.TotalDue) AS TotalPurchases
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    GROUP BY c.CustomerID, p.FirstName, p.LastName
)
SELECT
    CustomerName,
    TotalPurchases,
    NTILE(4) OVER (ORDER BY TotalPurchases DESC) AS Quartile,
    AVG(TotalPurchases) OVER (PARTITION BY NTILE(4) OVER (ORDER BY TotalPurchases DESC)) AS QuartileAvg
FROM CustomerTotals;

-- 20.1 Pivot table showing product categories as rows and years (2011-2014) as columns
SELECT 
    pc.Name AS Category,
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2011 THEN sod.LineTotal ELSE 0 END) AS [2011],
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2012 THEN sod.LineTotal ELSE 0 END) AS [2012],
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) AS [2013],
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) AS [2014],
    SUM(sod.LineTotal) AS Total
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY pc.Name;

-- 20.2 Pivot table showing departments as rows and gender as columns
SELECT Department, 
       SUM(CASE WHEN Gender = 'M' THEN 1 ELSE 0 END) AS Male,
       SUM(CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) AS Female
FROM (
    SELECT d.Name AS Department, e.Gender
    FROM HumanResources.Employee e
    JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
    JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
    WHERE edh.EndDate IS NULL
) AS DeptGender
GROUP BY Department
ORDER BY Department;

-- 20.3 Dynamic pivot table for quarterly sales
DECLARE @cols NVARCHAR(MAX), @sql NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(Quarter), ',')
FROM (
    SELECT DISTINCT CONCAT('Q', DATEPART(QUARTER, OrderDate), '-', YEAR(OrderDate)) AS Quarter
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
) AS x;


-- 21.1 Find products sold in both 2013 and 2014, and combine with products sold only in 2013
SELECT DISTINCT ProductID
FROM Sales
WHERE YEAR(SaleDate) = 2013
INTERSECT
SELECT DISTINCT ProductID
FROM Sales
WHERE YEAR(SaleDate) = 2014

UNION

SELECT DISTINCT ProductID
FROM Sales
WHERE YEAR(SaleDate) = 2013
EXCEPT
SELECT DISTINCT ProductID
FROM Sales
WHERE YEAR(SaleDate) = 2014;

-- 21.2 Compare product categories with high-value products (> $1000) to those with high-volume sales (> 1000 units)
SELECT DISTINCT CategoryID
FROM Products
WHERE Price > 1000
INTERSECT
SELECT DISTINCT P.CategoryID
FROM Products P
JOIN Sales S ON P.ProductID = S.ProductID
GROUP BY P.CategoryID
HAVING SUM(S.Quantity) > 1000;

-- 22.1 Declare variables for current year, total sales, average order value
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @TotalSales MONEY;
DECLARE @AvgOrderValue MONEY;

SELECT @TotalSales = SUM(TotalAmount), @AvgOrderValue = AVG(TotalAmount)
FROM Orders
WHERE YEAR(OrderDate) = @CurrentYear;

PRINT 'Year: ' + CAST(@CurrentYear AS VARCHAR);
PRINT 'Total Sales: $' + CAST(@TotalSales AS VARCHAR);
PRINT 'Average Order Value: $' + CAST(@AvgOrderValue AS VARCHAR);

-- 22.2 Check if a specific product exists in inventory
DECLARE @ProductID INT = 101;
IF EXISTS (SELECT 1 FROM Inventory WHERE ProductID = @ProductID)
BEGIN
    SELECT * FROM Inventory WHERE ProductID = @ProductID;
END
ELSE
BEGIN
    SELECT TOP 5 * FROM Products WHERE ProductName LIKE '%similar%' ORDER BY NEWID();
END

-- 22.3 Generate a monthly sales summary for each month in 2013
DECLARE @Month INT = 1;
WHILE @Month <= 12
BEGIN
    PRINT 'Month: ' + CAST(@Month AS VARCHAR);
    SELECT SUM(TotalAmount) AS MonthlySales
    FROM Orders
    WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) = @Month;
    SET @Month = @Month + 1;
END

-- 22.4 Error handling for product price update
BEGIN TRY
    BEGIN TRANSACTION
    UPDATE Products SET Price = Price * 1.10 WHERE CategoryID = 2;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    INSERT INTO ErrorLog (ErrorMessage, ErrorDate)
    VALUES (ERROR_MESSAGE(), GETDATE());
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
END CATCH;

-- 23.1 Scalar function to calculate customer lifetime value
CREATE FUNCTION dbo.CalculateCustomerLTV
(
    @CustomerID INT,
    @StartDate DATE,
    @EndDate DATE,
    @ActivityWeight FLOAT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @TotalSpent FLOAT = (
        SELECT SUM(TotalAmount)
        FROM Orders
        WHERE CustomerID = @CustomerID AND OrderDate BETWEEN @StartDate AND @EndDate
    );
    DECLARE @RecentActivity FLOAT = (
        SELECT COUNT(*) * @ActivityWeight
        FROM Orders
        WHERE CustomerID = @CustomerID AND OrderDate BETWEEN DATEADD(MONTH, -6, @EndDate) AND @EndDate
    );
    RETURN ISNULL(@TotalSpent, 0) + ISNULL(@RecentActivity, 0);
END;

-- 23.2 Multi-statement table-valued function
CREATE FUNCTION dbo.GetProductsByPriceRangeAndCategory
(
    @MinPrice MONEY,
    @MaxPrice MONEY,
    @CategoryID INT
)
RETURNS @Result TABLE
(
    ProductID INT,
    ProductName NVARCHAR(100),
    Price MONEY
)
AS
BEGIN
    IF @MinPrice < 0 OR @MaxPrice < 0 OR @MinPrice > @MaxPrice
        RETURN;

    INSERT INTO @Result
    SELECT ProductID, ProductName, Price
    FROM Products
    WHERE Price BETWEEN @MinPrice AND @MaxPrice AND CategoryID = @CategoryID;

    RETURN;
END;

-- 23.3 Inline table-valued function for employee hierarchy
CREATE FUNCTION dbo.GetEmployeesUnderManager(@ManagerID INT)
RETURNS TABLE
AS
RETURN
(
    WITH Hierarchy AS (
        SELECT EmployeeID, ManagerID, 0 AS Level, CAST(EmployeeName AS VARCHAR(MAX)) AS Path
        FROM Employees
        WHERE ManagerID = @ManagerID
        UNION ALL
        SELECT E.EmployeeID, E.ManagerID, H.Level + 1, H.Path + ' > ' + E.EmployeeName
        FROM Employees E
        INNER JOIN Hierarchy H ON E.ManagerID = H.EmployeeID
    )
    SELECT * FROM Hierarchy
);


-- -------------------------------------------------------------------------



CREATE PROCEDURE GetProductsByCategory
    @CategoryName NVARCHAR(100),
    @MinPrice MONEY,
    @MaxPrice MONEY
AS
BEGIN
    SET NOCOUNT ON;

    -- التحقق من المدخلات
    IF @MinPrice IS NULL OR @MaxPrice IS NULL OR @MinPrice > @MaxPrice
    BEGIN
        RAISERROR('Invalid price range.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Production.ProductCategory WHERE Name = @CategoryName)
    BEGIN
        RAISERROR('Category not found.', 16, 1);
        RETURN;
    END

    -- الاستعلام
    SELECT p.Name, p.ListPrice, pc.Name AS Category
    FROM Production.Product p
    INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.Name = @CategoryName AND p.ListPrice BETWEEN @MinPrice AND @MaxPrice
    ORDER BY p.ListPrice ASC;
END


-- -------------------------------------------

CREATE PROCEDURE UpdateProductPrice
    @ProductID INT,
    @NewPrice MONEY,
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OldPrice MONEY;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @OldPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;

        IF @OldPrice IS NULL
        BEGIN
            RAISERROR('Product not found.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Rule: Price can't increase more than 50%
        IF @NewPrice > @OldPrice * 1.5
        BEGIN
            RAISERROR('Price increase exceeds 50%%.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Update product
        UPDATE Production.Product
        SET ListPrice = @NewPrice
        WHERE ProductID = @ProductID;

        -- Insert into audit
        INSERT INTO dbo.ProductPriceAudit (ProductID, OldPrice, NewPrice, ModifiedBy)
        VALUES (@ProductID, @OldPrice, @NewPrice, @ModifiedBy);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

-- ------------------------------------------------------------------------
CREATE TRIGGER trg_InsertOrderDetails
ON Sales.vw_OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sales.SalesOrderHeader (OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, RevisionNumber)
    SELECT 
        i.OrderDate,
        DATEADD(DAY, 7, i.OrderDate),
        DATEADD(DAY, 2, i.OrderDate),
        1, -- Status
        1, -- OnlineOrderFlag
        'SO' + CAST(i.SalesOrderID AS VARCHAR(10)),
        1
    FROM inserted AS i;

    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice)
    SELECT 
        i.SalesOrderID,
        i.ProductID,
        i.OrderQty,
        i.UnitPrice
    FROM inserted AS i;
END;
 
 -- -----------------------------
 CREATE NONCLUSTERED INDEX IX_ActiveProducts
ON Production.Product(Name, ProductID)
WHERE SellEndDate IS NULL;

 CREATE NONCLUSTERED INDEX IX_RecentOrders
ON Sales.SalesOrderHeader(OrderDate, SalesOrderID)
WHERE OrderDate >= DATEADD(YEAR, -2, GETDATE());

SELECT Name, ProductID
FROM Production.Product
WHERE SellEndDate IS NULL;


SELECT OrderDate, SalesOrderID
FROM Sales.SalesOrderHeader
WHERE OrderDate >= DATEADD(YEAR, -2, GETDATE());

