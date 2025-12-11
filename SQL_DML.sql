-- =============================================
-- 1. SEED DATA (Populating the database)
-- =============================================

-- Insert Customers
INSERT INTO Customers (full_name, email, phone, shipping_address) VALUES
('Kwame Mensah', 'kwame.mensah@gmail.com', '024-123-4567', 'East Legon, Accra, Greater Accra Region'),
('Ama Osei', 'ama.osei@yahoo.com', '055-234-5678', 'Adum, Kumasi, Ashanti Region'),
('Kofi Agyeman', 'kofi.agyeman@outlook.com', '024-345-6789', 'Labone, Accra, Greater Accra Region'),
('Akosua Boateng', 'akosua.boateng@gmail.com', '055-456-7890', 'Ashaiman, Greater Accra Region'),
('Yaw Asante', 'yaw.asante@gmail.com', '024-567-8901', 'Sagnarigu, Tamale, Northern Region');

-- Insert Products
INSERT INTO Products (product_name, category, price) VALUES
('Laptop Pro', 'Electronics', 1200.00),
('Wireless Headphones', 'Electronics', 150.00),
('Ergonomic Chair', 'Furniture', 300.00),
('Coffee Maker', 'Appliances', 80.00),
('Running Shoes', 'Apparel', 120.00),
('Python Programming', 'Books', 45.00),
('Gaming Mouse', 'Electronics', 60.00),
('Standing Desk', 'Furniture', 450.00);

-- Insert Inventory (Initialize stock)
INSERT INTO Inventory (product_id, quantity_on_hand) VALUES
(1, 50), -- Laptop Pro
(2, 100), -- Headphones
(3, 20), -- Chair
(4, 30), -- Coffee Maker
(5, 75), -- Shoes
(6, 200), -- Book
(7, 60), -- Mouse
(8, 15); -- Standing Desk

-- Insert Orders (Some historical data)
INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
(1, '2023-10-01 10:00:00', 1350.00, 'Delivered'),
(2, '2023-10-05 14:30:00', 300.00, 'Delivered'),
(1, '2023-11-10 09:15:00', 45.00, 'Shipped'),
(3, '2023-11-15 11:20:00', 1200.00, 'Pending'),
(4, '2023-12-01 16:45:00', 1280.00, 'Pending');

-- Insert Order Items
-- Order 1: Laptop + Headphones
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 150.00);

-- Order 2: Chair
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
(2, 3, 1, 300.00);

-- Order 3: Book
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
(3, 6, 1, 45.00);

-- Order 4: Laptop
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
(4, 1, 1, 1200.00);

-- Order 5: Laptop + Coffee Maker
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
(5, 1, 1, 1200.00),
(5, 4, 1, 80.00);


-- =============================================
-- 2. BUSINESS KPIs
-- =============================================

-- KPI 1: Total Revenue
-- Calculate the total revenue from all 'Shipped' or 'Delivered' orders.
SELECT 
    SUM(total_amount) AS total_revenue
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered');

-- KPI 2: Top 10 Customers
-- Find the top 10 customers by their total spending.
SELECT 
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;

-- KPI 3: Best-Selling Products
-- List the top 5 best-selling products by quantity sold.
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- KPI 4: Monthly Sales Trend
-- Show the total sales revenue for each month.
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(total_amount) AS monthly_revenue
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- =============================================
-- 3. ANALYTICAL QUERIES (Window Functions)
-- =============================================

-- Analytic 1: Sales Rank by Category
-- Rank products by total sales revenue within their category.
WITH ProductSales AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.price_at_purchase) AS product_revenue
    FROM Products p
    JOIN Order_Items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
)
SELECT 
    category,
    product_name,
    product_revenue,
    RANK() OVER (PARTITION BY category ORDER BY product_revenue DESC) AS rank_in_category
FROM ProductSales;

-- Analytic 2: Customer Order Frequency
-- Show previous order date alongside current order date.
SELECT 
    c.full_name,
    o.order_id,
    o.order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;


-- =============================================
-- 4. PERFORMANCE OPTIMIZATION (Views & Stored Procedures)
-- =============================================

-- View: CustomerSalesSummary
-- Pre-calculate total amount spent by each customer.
CREATE OR REPLACE VIEW CustomerSalesSummary AS
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_lifetime_value
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email;

-- Stored Procedure: ProcessNewOrder
-- Handles stock checking, inventory updates, and order creation transactionally.
DROP PROCEDURE IF EXISTS ProcessNewOrder;

DELIMITER //

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;

    -- Start transaction
    START TRANSACTION;

    -- 1. Check current stock and price
    SELECT quantity_on_hand, price INTO v_stock, v_price
    FROM Products p
    JOIN Inventory i ON p.product_id = i.product_id
    WHERE p.product_id = p_product_id
    FOR UPDATE; -- Lock the rows to prevent race conditions

    -- 2. Check if enough stock exists
    IF v_stock >= p_quantity THEN
        -- a. Reduce Inventory
        UPDATE Inventory 
        SET quantity_on_hand = quantity_on_hand - p_quantity
        WHERE product_id = p_product_id;

        -- b. Create Order Record
        INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
        VALUES (p_customer_id, NOW(), (v_price * p_quantity), 'Pending');
        
        -- Get the generated Order ID
        SET v_order_id = LAST_INSERT_ID();

        -- c. Create Order Item Record
        INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase)
        VALUES (v_order_id, p_product_id, p_quantity, v_price);

        -- Commit transaction
        COMMIT;
        SELECT 'Order processed successfully' AS message, v_order_id AS new_order_id;
    ELSE
        -- Not enough stock, rollback
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for product';
    END IF;
END //

DELIMITER ;