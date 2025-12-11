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