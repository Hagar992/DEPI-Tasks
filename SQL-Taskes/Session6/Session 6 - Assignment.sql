-- 1. Customer Spending Analysis

-- عرض الأعمدة في جدول orders(اختبار)
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'orders' AND TABLE_SCHEMA = 'sales';


DECLARE @CustomerID INT = 1;
DECLARE @TotalSpent MONEY;

SELECT @TotalSpent = SUM((oi.quantity * oi.list_price) * (1 - oi.discount))
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = @CustomerID;

IF @TotalSpent > 5000
    PRINT 'VIP Customer - Total Spent: $' + CAST(@TotalSpent AS VARCHAR);
ELSE
    PRINT 'Regular Customer - Total Spent: $' + CAST(@TotalSpent AS VARCHAR);


-- 2. Product Price Threshold Report
DECLARE @Threshold MONEY = 1500;
DECLARE @Count INT;

SELECT @Count = COUNT(*) FROM production.products WHERE list_price > @Threshold;
PRINT 'Threshold: $' + CAST(@Threshold AS VARCHAR) + ' - Products above threshold: ' + CAST(@Count AS VARCHAR);

-- 3. Staff Performance Calculator
SELECT TOP 1 * FROM sales.orders;


DECLARE @StaffID INT = 2, @Year INT = 2017, @TotalSales MONEY;

SELECT @TotalSales = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.order_items oi
JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.staff_id = @StaffID AND YEAR(o.order_date) = @Year;

PRINT 'Staff ID: ' + CAST(@StaffID AS VARCHAR) + 
      ' - Year: ' + CAST(@Year AS VARCHAR) + 
      ' - Total Sales: $' + CAST(@TotalSales AS VARCHAR);


-- 5. Inventory Level Check
DECLARE @Qty INT;
SELECT @Qty = quantity FROM production.stocks WHERE product_id = 1 AND store_id = 1;

IF @Qty > 20
    PRINT 'Well stocked';
ELSE IF @Qty BETWEEN 10 AND 20
    PRINT 'Moderate stock';
ELSE IF @Qty < 10
    PRINT 'Low stock - reorder needed';

-- 6. WHILE loop to update low-stock items
DECLARE @Counter INT = 0;

WHILE @Counter < (SELECT COUNT(*) FROM production.stocks WHERE quantity < 5)
BEGIN
    UPDATE TOP (3) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;

    SET @Counter = @Counter + 3;
    PRINT 'Updated 3 low-stock products';
END

-- 7. Product Price Categorization
SELECT 
    product_id,
    product_name,
    list_price,
    CASE 
        WHEN list_price < 300 THEN 'Budget'
        WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
        ELSE 'Luxury'
    END AS PriceCategory
FROM production.products;

-- 8. Customer Order Validation
IF EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = 5)
    SELECT COUNT(*) AS OrderCount FROM sales.orders WHERE customer_id = 5;
ELSE
    PRINT 'Customer ID 5 not found';

-- 9. Shipping Cost Calculator Function
CREATE FUNCTION dbo.CalculateShipping(@Total MONEY)
RETURNS MONEY
AS
BEGIN
    RETURN (
        CASE 
            WHEN @Total > 100 THEN 0
            WHEN @Total BETWEEN 50 AND 99.99 THEN 5.99
            ELSE 12.99
        END
    )
END;

-- 10. Product Category Function
CREATE FUNCTION dbo.GetProductsByPriceRange(@Min MONEY, @Max MONEY)
RETURNS TABLE
AS
RETURN (
    SELECT p.product_name, b.brand_name, c.category_name, p.list_price
    FROM production.products p
    JOIN production.brands b ON p.brand_id = b.brand_id
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE p.list_price BETWEEN @Min AND @Max
);

-- 11. Customer Sales Summary Function
CREATE FUNCTION dbo.GetCustomerYearlySummary(@CustomerID INT)
RETURNS @Summary TABLE (
    Year INT,
    TotalOrders INT,
    TotalSpent MONEY,
    AvgOrder MONEY
)
AS
BEGIN
    INSERT INTO @Summary
    SELECT 
        YEAR(o.order_date) AS Year,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS TotalSpent,
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS AvgOrder
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY YEAR(o.order_date);

    RETURN;
END;


-- 12. Discount Calculation Function
CREATE FUNCTION dbo.CalculateBulkDiscount(@Qty INT)
RETURNS INT
AS
BEGIN
    RETURN (
        CASE 
            WHEN @Qty BETWEEN 1 AND 2 THEN 0
            WHEN @Qty BETWEEN 3 AND 5 THEN 5
            WHEN @Qty BETWEEN 6 AND 9 THEN 10
            ELSE 15
        END
    );
END;

-- 13. Customer Order History Procedure
CREATE PROCEDURE sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_amount
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
      AND (@StartDate IS NULL OR o.order_date >= @StartDate)
      AND (@EndDate IS NULL OR o.order_date <= @EndDate)
    GROUP BY o.order_id, o.order_date
    ORDER BY o.order_date;
END;


-- 14. Inventory Restock Procedure
CREATE PROCEDURE sp_RestockProduct
    @StoreID INT,
    @ProductID INT,
    @RestockQty INT,
    @OldQty INT OUTPUT,
    @NewQty INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN
    SELECT @OldQty = quantity FROM production.stocks WHERE store_id = @StoreID AND product_id = @ProductID;
    UPDATE production.stocks SET quantity = quantity + @RestockQty WHERE store_id = @StoreID AND product_id = @ProductID;
    SELECT @NewQty = quantity FROM production.stocks WHERE store_id = @StoreID AND product_id = @ProductID;
    SET @Success = 1;
END;

-- 15. Order Processing Procedure
CREATE PROCEDURE sp_ProcessNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @StoreID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insert logic here (order + stock update)
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT ERROR_MESSAGE();
    END CATCH
END;

-- 16. Dynamic Product Search Procedure
CREATE PROCEDURE sp_SearchProducts
    @SearchTerm NVARCHAR(100) = NULL,
    @CategoryID INT = NULL,
    @MinPrice MONEY = NULL,
    @MaxPrice MONEY = NULL,
    @SortColumn NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'SELECT * FROM production.products WHERE 1=1';

    IF @SearchTerm IS NOT NULL
        SET @SQL += ' AND product_name LIKE ''%' + @SearchTerm + '%''';
    IF @CategoryID IS NOT NULL
        SET @SQL += ' AND category_id = ' + CAST(@CategoryID AS VARCHAR);
    IF @MinPrice IS NOT NULL
        SET @SQL += ' AND list_price >= ' + CAST(@MinPrice AS VARCHAR);
    IF @MaxPrice IS NOT NULL
        SET @SQL += ' AND list_price <= ' + CAST(@MaxPrice AS VARCHAR);
    IF @SortColumn IS NOT NULL
        SET @SQL += ' ORDER BY ' + QUOTENAME(@SortColumn);

    EXEC sp_executesql @SQL;
END;

-- 17. Staff Bonus Calculation System
DECLARE @StartDate DATE = '2025-01-01', @EndDate DATE = '2025-03-31';

SELECT staff_id,
       SUM(total_amount) AS QuarterlySales,
       CASE 
           WHEN SUM(total_amount) > 30000 THEN SUM(total_amount) * 0.1
           WHEN SUM(total_amount) > 15000 THEN SUM(total_amount) * 0.05
           ELSE 0
       END AS Bonus
FROM sales.orders
WHERE order_date BETWEEN @StartDate AND @EndDate
GROUP BY staff_id;

-- 18. Smart Inventory Management

SELECT s.product_id,
       s.quantity,
       p.category_id,
       CASE 
           WHEN s.quantity < 5 AND p.category_id = 1 THEN 'Restock 20'
           WHEN s.quantity < 10 AND p.category_id = 2 THEN 'Restock 15'
           WHEN s.quantity < 15 THEN 'Restock 10'
           ELSE 'Sufficient'
       END AS RestockAction
FROM production.stocks s
JOIN production.products p ON s.product_id = p.product_id;


-- 19. Customer Loyalty Tier Assignment
SELECT c.customer_id,
       c.first_name + ' ' + c.last_name AS FullName,
       COALESCE(SUM(o.total_amount), 0) AS TotalSpent,
       CASE 
           WHEN SUM(o.total_amount) >= 10000 THEN 'Platinum'
           WHEN SUM(o.total_amount) >= 5000 THEN 'Gold'
           WHEN SUM(o.total_amount) >= 1000 THEN 'Silver'
           ELSE 'Bronze'
       END AS Tier
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 20. Product Lifecycle Management
CREATE PROCEDURE sp_DiscontinueProduct
    @ProductID INT,
    @ReplacementID INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM sales.order_items WHERE product_id = @ProductID)
    BEGIN
        IF @ReplacementID IS NOT NULL
            UPDATE sales.order_items SET product_id = @ReplacementID WHERE product_id = @ProductID;
    END
    DELETE FROM production.stocks WHERE product_id = @ProductID;
    DELETE FROM production.products WHERE product_id = @ProductID;
    PRINT 'Product discontinued successfully';
END;

-- 21. Advanced Analytics Query
SELECT 
    FORMAT(o.order_date, 'yyyy-MM') AS Month,
    o.staff_id,
    COUNT(*) AS OrderCount,
    SUM(oi.quantity * oi.list_price) AS TotalSales,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS ProductsSold
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.categories c ON p.category_id = c.category_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM'), o.staff_id, c.category_name;


-- 22. Data Validation System
CREATE PROCEDURE sp_ValidateNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @CustomerID)
    BEGIN
        RAISERROR('Invalid customer ID', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM production.products WHERE product_id = @ProductID)
    BEGIN
        RAISERROR('Invalid product ID', 16, 1);
        RETURN;
    END

    IF (SELECT quantity FROM production.stocks WHERE product_id = @ProductID) < @Quantity
    BEGIN
        RAISERROR('Insufficient stock', 16, 1);
        RETURN;
    END

    PRINT 'Order is valid';
END;
