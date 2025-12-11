-- Database Schema for Inventory and Order Management System

-- Drop tables if they exist to start fresh 
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- 1. Create Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    shipping_address VARCHAR(255) NOT NULL
);
-- 2. Create Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_product_price CHECK (price >= 0)
);


-- 3. Create Inventory Table
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_on_hand INT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_inventory_qty CHECK (quantity_on_hand >= 0)
);