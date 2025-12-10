# E-Commerce Inventory & Order Management System - ERD

## Entity-Relationship Diagram (Text Format)

---

## Entities and Attributes

### 1. CUSTOMERS
**Purpose**: Store customer information for order placement and shipping

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| customer_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each customer |
| full_name | VARCHAR(100) | NOT NULL | Customer's full name |
| email | VARCHAR(100) | NOT NULL, UNIQUE | Customer's email address |
| phone | VARCHAR(20) | NOT NULL | Customer's phone number |
| shipping_address | VARCHAR(255) | NOT NULL | Customer's default shipping address |

**Business Rules**:
- Each customer must have a unique email address
- All fields are required for account creation

---

### 2. PRODUCTS
**Purpose**: Store product catalog information

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| product_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each product |
| product_name | VARCHAR(150) | NOT NULL | Name of the product |
| category | VARCHAR(50) | NOT NULL | Product category (Electronics, Apparel, Books, etc.) |
| price | DECIMAL(10,2) | NOT NULL, CHECK (price >= 0) | Current selling price of the product |

**Business Rules**:
- Product prices must be non-negative
- Product names must be unique within the same category (optional constraint)

---

### 3. INVENTORY
**Purpose**: Track current stock levels for products

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| inventory_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for inventory record |
| product_id | INT | FOREIGN KEY, NOT NULL, UNIQUE | Reference to Products table |
| quantity_on_hand | INT | NOT NULL, CHECK (quantity_on_hand >= 0) | Current stock quantity available |
| last_updated | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Last inventory update timestamp |

**Business Rules**:
- Each product has exactly one inventory record (1:1 relationship)
- Stock quantity cannot be negative
- Inventory is automatically updated when orders are processed

---

### 4. ORDERS
**Purpose**: Store order header information

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| order_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each order |
| customer_id | INT | FOREIGN KEY, NOT NULL | Reference to Customers table |
| order_date | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date and time when order was placed |
| total_amount | DECIMAL(10,2) | NOT NULL, CHECK (total_amount >= 0) | Total order amount |
| order_status | VARCHAR(20) | NOT NULL, DEFAULT 'Pending' | Order status (Pending, Shipped, Delivered, Cancelled) |

**Business Rules**:
- Total amount is calculated from order items
- Valid order statuses: 'Pending', 'Shipped', 'Delivered', 'Cancelled'
- Order status transitions: Pending → Shipped → Delivered

---

### 5. ORDER_ITEMS
**Purpose**: Bridge table linking orders to products (handles many-to-many relationship)

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| order_item_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each order item |
| order_id | INT | FOREIGN KEY, NOT NULL | Reference to Orders table |
| product_id | INT | FOREIGN KEY, NOT NULL | Reference to Products table |
| quantity | INT | NOT NULL, CHECK (quantity > 0) | Quantity of product ordered |
| price_at_purchase | DECIMAL(10,2) | NOT NULL, CHECK (price_at_purchase >= 0) | Product price at time of order (historical price) |

**Business Rules**:
- Combination of (order_id, product_id) should be unique (composite unique constraint)
- Price at purchase may differ from current product price
- Quantity must be positive (at least 1)
- Line total = quantity × price_at_purchase

---

## Relationships

### 1. CUSTOMERS ─────< ORDERS
**Type**: One-to-Many (1:M)
- **Cardinality**: One customer can place many orders
- **Foreign Key**: orders.customer_id → customers.customer_id
- **Referential Integrity**: 
  - ON DELETE: RESTRICT (cannot delete customer with existing orders)
  - ON UPDATE: CASCADE (update cascades to orders)

---

### 2. PRODUCTS ───── INVENTORY
**Type**: One-to-One (1:1)
- **Cardinality**: Each product has exactly one inventory record
- **Foreign Key**: inventory.product_id → products.product_id (UNIQUE)
- **Referential Integrity**: 
  - ON DELETE: CASCADE (delete inventory when product is deleted)
  - ON UPDATE: CASCADE

---

### 3. ORDERS ─────< ORDER_ITEMS >───── PRODUCTS
**Type**: Many-to-Many (M:N) resolved through ORDER_ITEMS bridge table
- **Left Relationship (ORDERS ─────< ORDER_ITEMS)**:
  - One order can contain many order items
  - Foreign Key: order_items.order_id → orders.order_id
  - ON DELETE: CASCADE (delete order items when order is deleted)
  - ON UPDATE: CASCADE

- **Right Relationship (PRODUCTS ─────< ORDER_ITEMS)**:
  - One product can appear in many order items
  - Foreign Key: order_items.product_id → products.product_id
  - ON DELETE: RESTRICT (cannot delete product that has been ordered)
  - ON UPDATE: CASCADE

---

## ER Diagram (ASCII Representation)

```
┌─────────────────┐
│   CUSTOMERS     │
├─────────────────┤
│ PK customer_id  │
│    full_name    │
│    email (UQ)   │
│    phone        │
│ shipping_address│
└────────┬────────┘
         │
         │ 1
         │
         │ places
         │
         │ M
         ▼
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│     ORDERS      │    M    │  ORDER_ITEMS     │    M    │    PRODUCTS     │
├─────────────────┤◄────────┤──────────────────┤────────►├─────────────────┤
│ PK order_id     │ contains│ PK order_item_id │ contains│ PK product_id   │
│ FK customer_id  │         │ FK order_id      │         │    product_name │
│    order_date   │         │ FK product_id    │         │    category     │
│    total_amount │         │    quantity      │         │    price        │
│    order_status │         │ price_at_purchase│         └────────┬────────┘
└─────────────────┘         └──────────────────┘                  │
                                                                   │ 1
                                                                   │
                                                                   │ has
                                                                   │
                                                                   │ 1
                                                                   ▼
                                                        ┌─────────────────┐
                                                        │   INVENTORY     │
                                                        ├─────────────────┤
                                                        │ PK inventory_id │
                                                        │ FK product_id(UQ)│
                                                        │ quantity_on_hand│
                                                        │   last_updated  │
                                                        └─────────────────┘
```

---

## Normalization Notes

### Third Normal Form (3NF) Compliance:

1. **First Normal Form (1NF)**:
   - ✓ All tables have primary keys
   - ✓ All attributes contain atomic values
   - ✓ No repeating groups

2. **Second Normal Form (2NF)**:
   - ✓ All non-key attributes are fully functionally dependent on the primary key
   - ✓ No partial dependencies (all tables have single-column PKs except for potential composite unique constraint)

3. **Third Normal Form (3NF)**:
   - ✓ No transitive dependencies
   - ✓ `price_at_purchase` in ORDER_ITEMS is intentionally denormalized to capture historical pricing
   - ✓ `total_amount` in ORDERS is a calculated field (can be derived) but stored for performance

### Design Decisions:

1. **Inventory as Separate Table**: 
   - Separates product definition from stock tracking
   - Allows for future expansion (multiple warehouses, stock history)

2. **Historical Pricing**: 
   - `price_at_purchase` in ORDER_ITEMS preserves the price at time of sale
   - Essential for accurate historical reporting and refunds

3. **Order Status**: 
   - Using VARCHAR instead of a separate status table for simplicity
   - Could be normalized further with a STATUS table if needed

4. **Calculated Fields**:
   - `total_amount` in ORDERS stored for query performance (alternative: calculate on-the-fly)

---

## Indexes Recommendation

For optimal query performance, consider these indexes:

- `CUSTOMERS`: Index on `email` (unique), `full_name`
- `PRODUCTS`: Index on `category`, `product_name`
- `ORDERS`: Index on `customer_id`, `order_date`, `order_status`
- `ORDER_ITEMS`: Composite index on `(order_id, product_id)`, index on `product_id`
- `INVENTORY`: Unique index on `product_id`

---

## Additional Constraints Summary

1. **CHECK Constraints**:
   - `products.price >= 0`
   - `inventory.quantity_on_hand >= 0`
   - `orders.total_amount >= 0`
   - `order_items.quantity > 0`
   - `order_items.price_at_purchase >= 0`

2. **UNIQUE Constraints**:
   - `customers.email`
   - `inventory.product_id`
   - Composite: `(order_items.order_id, order_items.product_id)` - optional but recommended

3. **DEFAULT Values**:
   - `orders.order_status = 'Pending'`
   - `orders.order_date = CURRENT_TIMESTAMP`
   - `inventory.last_updated = CURRENT_TIMESTAMP`

---

## Future Enhancements (Optional)

Potential expansions for the database:
- **Categories Table**: Normalize product categories into separate table
- **Order Status History**: Track status changes over time
- **Multiple Addresses**: Allow customers to have multiple shipping addresses
- **Product Images**: Add product image URLs or blob storage
- **Warehouse Locations**: Multi-location inventory tracking
- **Suppliers**: Track product suppliers
- **Reviews**: Customer product reviews and ratings
