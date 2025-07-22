
-- Assignment 1: Non-clustered index on email in sales.customers
CREATE NONCLUSTERED INDEX IX_Customers_Email
ON sales.customers (email);

-- Assignment 2: Composite index on category_id and brand_id in production.products
CREATE NONCLUSTERED INDEX IX_Products_Category_Brand
ON production.products (category_id, brand_id);

-- Assignment 3: Index on order_date in sales.orders including customer_id, store_id, order_status
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
ON sales.orders (order_date)
INCLUDE (customer_id, store_id, order_status);

-- Assignment 4: Trigger to insert welcome log when a new customer is added
CREATE TABLE sales.customer_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    action VARCHAR(50),
    log_date DATETIME DEFAULT GETDATE()
);

GO

CREATE TRIGGER trg_InsertCustomerLog
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.customer_log (customer_id, action)
    SELECT customer_id, 'Welcome New Customer'
    FROM INSERTED;
END;

-- Assignment 5: Trigger to track price changes in products
CREATE TABLE production.price_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME DEFAULT GETDATE(),
    changed_by VARCHAR(100)
);

GO

CREATE TRIGGER trg_PriceChange
ON production.products
AFTER UPDATE
AS
BEGIN
    IF UPDATE(list_price)
    BEGIN
        INSERT INTO production.price_history (product_id, old_price, new_price, changed_by)
        SELECT d.product_id, d.list_price, i.list_price, SYSTEM_USER
        FROM INSERTED i
        INNER JOIN DELETED d ON i.product_id = d.product_id
        WHERE i.list_price != d.list_price;
    END
END;

-- Assignment 6: Prevent deletion of categories with products
CREATE TRIGGER trg_PreventCategoryDelete
ON production.categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM production.products p
        INNER JOIN DELETED d ON p.category_id = d.category_id
    )
    BEGIN
        RAISERROR ('Cannot delete category with associated products.', 16, 1);
        RETURN;
    END

    DELETE FROM production.categories
    WHERE category_id IN (SELECT category_id FROM DELETED);
END;

-- Assignment 7: Reduce stock quantity when new order_item is inserted
CREATE TRIGGER trg_UpdateStockOnOrderItemInsert
ON sales.order_items
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.quantity = s.quantity - i.quantity
    FROM production.stocks s
    INNER JOIN INSERTED i ON s.product_id = i.product_id AND s.store_id = i.store_id;
END;

-- Assignment 8: Log all new orders into order_audit table
CREATE TABLE sales.order_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    customer_id INT,
    store_id INT,
    staff_id INT,
    order_date DATE,
    audit_timestamp DATETIME DEFAULT GETDATE()
);

GO

CREATE TRIGGER trg_LogNewOrder
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_audit (order_id, customer_id, store_id, staff_id, order_date)
    SELECT order_id, customer_id, store_id, staff_id, order_date
    FROM INSERTED;
END;


