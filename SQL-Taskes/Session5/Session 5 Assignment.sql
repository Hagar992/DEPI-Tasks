--1.Write a query that classifies all products into price categories:
--Products under $300: "Economy"
--Products $300-$999: "Standard"
--Products $1000-$2499: "Premium"
--Products $2500 and above: "Luxury"
SELECT 
    product_name,
    list_price,
    CASE 
        WHEN list_price < 300 THEN 'Economy'
        WHEN list_price BETWEEN 300 AND 999 THEN 'Standard'
        WHEN list_price BETWEEN 1000 AND 2499 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_category
FROM production.products;


--2.Create a query that shows order processing information with user-friendly status descriptions:
--Status 1: "Order Received"
--Status 2: "In Preparation"
--Status 3: "Order Cancelled"
--Status 4: "Order Delivered"
--Also add a priority level:
--Orders with status 1 older than 5 days: "URGENT"
--Orders with status 2 older than 3 days: "HIGH"
--All other orders: "NORMAL"
SELECT 
    order_id,
    order_date,
    order_status,
    CASE 
        WHEN order_status = 1 THEN 'Order Received'
        WHEN order_status = 2 THEN 'In Preparation'
        WHEN order_status = 3 THEN 'Order Cancelled'
        WHEN order_status = 4 THEN 'Order Delivered'
    END AS status_desc,
    CASE 
        WHEN order_status = 1 AND DATEDIFF(DAY, order_date, GETDATE()) > 5 THEN 'URGENT'
        WHEN order_status = 2 AND DATEDIFF(DAY, order_date, GETDATE()) > 3 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS priority
FROM sales.orders;


--3.Write a query that categorizes staff based on the number of orders they've handled:
--0 orders: "New Staff"
--1-10 orders: "Junior Staff"
--11-25 orders: "Senior Staff"
--26+ orders: "Expert Staff"
SELECT 
    s.staff_id,
    s.first_name + ' ' + s.last_name AS staff_name,
    COUNT(o.order_id) AS order_count,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'New Staff'
        WHEN COUNT(o.order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'
        WHEN COUNT(o.order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
        ELSE 'Expert Staff'
    END AS staff_level
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;


--4.Create a query that handles missing customer contact information:
--Use ISNULL to replace missing phone numbers with "Phone Not Available"
--Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
--Show complete customer information
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    ISNULL(phone, 'Phone Not Available') AS contact_phone,
    COALESCE(phone, email, 'No Contact Method') AS preferred_contact,
    email,
    city,
    state
FROM sales.customers;


--5.Write a query that safely calculates price per unit in stock:
--Use NULLIF to prevent division by zero when quantity is 0
--Use ISNULL to show 0 when no stock exists
--Include stock status using CASE WHEN
--Only show products from store_id = 1
SELECT 
    p.product_id,
    p.product_name,
    s.quantity,
    p.list_price,
    ISNULL(p.list_price / NULLIF(s.quantity, 0), 0) AS price_per_unit,
    CASE 
        WHEN s.quantity = 0 THEN 'Out of Stock'
        WHEN s.quantity < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.store_id = 1;



--6.Create a query that formats complete addresses safely:
--Use COALESCE for each address component
--Create a formatted_address field that combines all components
--Handle missing ZIP codes gracefully

SELECT TOP 1 * 
FROM sales.customers;

SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    COALESCE(street, '') + ', ' + 
    COALESCE(city, '') + ', ' + 
    COALESCE(state, '') + ' ' + 
    COALESCE(zip_code, 'No ZIP') AS formatted_address
FROM sales.customers;


--7.Use a CTE to find customers who have spent more than $1,500 total:
--Create a CTE that calculates total spending per customer
--Join with customer information
--Show customer details and spending
--Order by total_spent descending
WITH customer_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    cs.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    cs.total_spent
FROM customer_spending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > 1500
ORDER BY cs.total_spent DESC;


--8.Create a multi-CTE query for category analysis:
--CTE 1: Calculate total revenue per category
--CTE 2: Calculate average order value per category
--Main query: Combine both CTEs
--Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"
WITH category_revenue AS (
    SELECT 
        c.category_id,
        c.category_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
),
category_avg_order AS (
    SELECT 
        c.category_id,
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avg_order_value
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id
)
SELECT 
    r.category_name,
    r.total_revenue,
    a.avg_order_value,
    CASE 
        WHEN r.total_revenue > 50000 THEN 'Excellent'
        WHEN r.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance
FROM category_revenue r
JOIN category_avg_order a ON r.category_id = a.category_id;


--9.Use CTEs to analyze monthly sales trends:
--CTE 1: Calculate monthly sales totals
--CTE 2: Add previous month comparison
--Show growth percentage
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY FORMAT(order_date, 'yyyy-MM')
),
sales_with_prev AS (
    SELECT 
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly_sales
)
SELECT 
    month,
    total_sales,
    prev_month_sales,
    ROUND(100.0 * (total_sales - ISNULL(prev_month_sales, 0)) / 
          NULLIF(prev_month_sales, 0), 2) AS growth_percent
FROM sales_with_prev;


--10.Create a query that ranks products within each category:
--Use ROW_NUMBER() to rank by price (highest first)
--Use RANK() to handle ties
--Use DENSE_RANK() for continuous ranking
--Only show top 3 products per category
SELECT * FROM (
    SELECT 
        p.product_name,
        c.category_name,
        p.list_price,
        ROW_NUMBER() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS row_num,
        RANK() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS rank_pos,
        DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS dense_rank_pos
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
) ranked
WHERE row_num <= 3;


--11.Rank customers by their total spending:
--Calculate total spending per customer
--Use RANK() for customer ranking
--Use NTILE(5) to divide into 5 spending groups
--Use CASE for tiers: 1="VIP", 2="Gold", 3="Silver", 4="Bronze", 5="Standard"
WITH customer_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    cs.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    cs.total_spent,
    RANK() OVER (ORDER BY cs.total_spent DESC) AS spend_rank,
    NTILE(5) OVER (ORDER BY cs.total_spent DESC) AS spending_group,
    CASE 
        WHEN NTILE(5) OVER (ORDER BY cs.total_spent DESC) = 1 THEN 'VIP'
        WHEN NTILE(5) OVER (ORDER BY cs.total_spent DESC) = 2 THEN 'Gold'
        WHEN NTILE(5) OVER (ORDER BY cs.total_spent DESC) = 3 THEN 'Silver'
        WHEN NTILE(5) OVER (ORDER BY cs.total_spent DESC) = 4 THEN 'Bronze'
        ELSE 'Standard'
    END AS tier
FROM customer_spending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id;


--12.Create a comprehensive store performance ranking:
--Rank stores by total revenue
--Rank stores by number of orders
--Use PERCENT_RANK() to show percentile performance
WITH store_perf AS (
    SELECT 
        s.store_id,
        s.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
)
SELECT 
    store_name,
    total_revenue,
    total_orders,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_orders DESC) AS orders_rank,
    PERCENT_RANK() OVER (ORDER BY total_revenue) AS percentile
FROM store_perf;


--13.Create a PIVOT table showing product counts by category and brand:
--Rows: Categories
--Columns: Top 4 brands (Electra, Haro, Trek, Surly)
--Values: Count of products
SELECT *
FROM (
    SELECT 
        c.category_name,
        b.brand_name
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE b.brand_name IN ('Electra', 'Haro', 'Trek', 'Surly')
) AS source
PIVOT (
    COUNT(brand_name)
    FOR brand_name IN ([Electra], [Haro], [Trek], [Surly])
) AS pivot_table;


--14.Create a PIVOT showing monthly sales revenue by store:
--Rows: Store names
--Columns: Months (Jan through Dec)
--Values: Total revenue
--Add a total column
SELECT *
FROM (
    SELECT 
        s.store_name,
        FORMAT(o.order_date, 'MMM') AS month,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN sales.stores s ON o.store_id = s.store_id
    GROUP BY s.store_name, FORMAT(o.order_date, 'MMM')
) AS source
PIVOT (
    SUM(revenue)
    FOR month IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) AS monthly_sales;


--15.PIVOT order statuses across stores:
--Rows: Store names
--Columns: Order statuses (Pending, Processing, Completed, Rejected)
--Values: Count of orders
SELECT *
FROM (
    SELECT 
        s.store_name,
        CASE 
            WHEN o.order_status = 1 THEN 'Pending'
            WHEN o.order_status = 2 THEN 'Processing'
            WHEN o.order_status = 3 THEN 'Completed'
            ELSE 'Rejected'
        END AS order_status
    FROM sales.orders o
    JOIN sales.stores s ON o.store_id = s.store_id
) AS source
PIVOT (
    COUNT(order_status)
    FOR order_status IN ([Pending], [Processing], [Completed], [Rejected])
) AS pivot_status;


--16.Create a PIVOT comparing sales across years:
--Rows: Brand names
--Columns: Years (2016, 2017, 2018)
--Values: Total revenue
--Include percentage growth calculations
WITH yearly_sales AS (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS sales_year,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM production.products p
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    JOIN sales.orders o ON o.order_id = oi.order_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE YEAR(o.order_date) IN (2016, 2017, 2018)
    GROUP BY b.brand_name, YEAR(o.order_date)
)
SELECT *,
       ROUND(100.0 * ([2018] - [2017]) / NULLIF([2017], 0), 2) AS growth_17_18
FROM yearly_sales
PIVOT (
    SUM(revenue)
    FOR sales_year IN ([2016], [2017], [2018])
) AS pivot_years;


--17.Use UNION to combine different product availability statuses:
--Query 1: In-stock products (quantity > 0)
--Query 2: Out-of-stock products (quantity = 0 or NULL)
--Query 3: Discontinued products (not in stocks table)
-- In-stock
-- In Stock
SELECT p.product_name, 'In Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0
UNION
-- Out-of-stock
SELECT p.product_name, 'Out of Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
-- Discontinued
SELECT p.product_name, 'Discontinued' AS status
FROM production.products p
WHERE p.product_id NOT IN (SELECT product_id FROM production.stocks);



--18.Use INTERSECT to find loyal customers:
--Find customers who bought in both 2017 AND 2018
--Show their purchase patterns
-- 2017 Customers
SELECT DISTINCT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2017

INTERSECT

-- 2018 Customers
SELECT DISTINCT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2018;


--19.Use multiple set operators to analyze product distribution:
--INTERSECT: Products available in all 3 stores
--EXCEPT: Products available in store 1 but not in store 2
--UNION: Combine above results with different labels
-- Products in all 3 stores
SELECT product_id FROM production.stocks WHERE store_id = 1
INTERSECT
SELECT product_id FROM production.stocks WHERE store_id = 2
INTERSECT
SELECT product_id FROM production.stocks WHERE store_id = 3

UNION

-- Products in store 1 but not in 2
SELECT product_id FROM production.stocks WHERE store_id = 1
EXCEPT
SELECT product_id FROM production.stocks WHERE store_id = 2;


--20.Complex set operations for customer retention:
--Find customers who bought in 2016 but not in 2017 (lost customers)
--Find customers who bought in 2017 but not in 2016 (new customers)
--Find customers who bought in both years (retained customers)
--Use UNION ALL to combine all three groups
-- Lost Customers: bought in 2016 not in 2017
SELECT customer_id, 'Lost' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2016
EXCEPT
SELECT customer_id, 'Lost' FROM sales.orders WHERE YEAR(order_date) = 2017

UNION ALL

-- New Customers: bought in 2017 not in 2016
SELECT customer_id, 'New' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2017
EXCEPT
SELECT customer_id, 'New' FROM sales.orders WHERE YEAR(order_date) = 2016

UNION ALL

-- Retained Customers: bought in both years
SELECT customer_id, 'Retained' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2016
INTERSECT
SELECT customer_id, 'Retained' FROM sales.orders WHERE YEAR(order_date) = 2017;
