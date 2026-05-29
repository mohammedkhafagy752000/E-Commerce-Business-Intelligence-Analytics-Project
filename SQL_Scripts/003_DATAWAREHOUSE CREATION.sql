CREATE DATABASE ECOMMERCE_DW;
USE ECOMMERCE_DW;
--1. CREATE Dimension Categories TABLE
CREATE TABLE DMCategories
(
CATKEY INT PRIMARY KEY IDENTITY(1,1),
product_category_name VARCHAR(50) ,
product_category_name_english VARCHAR (50)
);
--2. CREATE Dimension PRODUCTS TABLE
CREATE TABLE DMPRODUCTS 
(
PRDKEY INT PRIMARY KEY IDENTITY(1,1),
product_id VARCHAR(50) ,
product_category_name VARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g DECIMAL(10,2),
product_length_cm DECIMAL(10,2),
product_height_cm DECIMAL(10,2),
product_width_cm DECIMAL(10,2)
);
--3. CREATE Dimension Geolocation TABLE
CREATE TABLE DMGeolocation 
(
GEOKEY INT PRIMARY KEY IDENTITY(1,1),
geolocation_zip_code_prefix int ,
geolocation_lat DECIMAL(9,6),
geolocation_lng DECIMAL(9,6),
geolocation_city varchar(50),
geolocation_state varchar(20)
);
--4. CREATE Dimension Customers TABLE
Create table DMCustomers 
(
CSTKEY INT PRIMARY KEY IDENTITY(1,1),
customer_id varchar (50) ,
customer_unique_id varchar(50) ,
customer_zip_code_prefix int,
customer_city varchar(50),
customer_state varchar(10),
IS_CURRENT BIT,
EFFECTIVE_DATE DATE DEFAULT GETDATE(),
END_DATE DATE DEFAULT '1/1/2050'
);
--5. CREATE Dimension Sellers TABLE
CREATE TABLE DMSellers 
(
SLRKEY INT PRIMARY KEY IDENTITY(1,1),
seller_id varchar(50) ,
seller_zip_code_prefix int,
seller_city varchar (50),
seller_state varchar(20),
IS_CURRENT BIT,
EFFECTIVE_DATE DATE DEFAULT GETDATE(),
END_DATE DATE DEFAULT '1/1/2050'
);
--6. DIM DATE CRATION
CREATE TABLE DIM_DATE (
DateKey INT  PRIMARY KEY,       
FullDate DATE NOT NULL,        
Year INT NOT NULL,             
Quarter INT NOT NULL,         
Month INT NOT NULL,           
MonthName VARCHAR(20),         
Day INT NOT NULL,              
DayName VARCHAR(20),           
DayOfWeek INT NOT NULL,        
IsWeekend BIT DEFAULT 0        
);

--7. CREATE FACTOrders TABLE (Optimized for Aggregated Metrics)
CREATE TABLE FACTOrders 
(
    ORDKEY INT PRIMARY KEY IDENTITY(1,1),
    CATKEY INT,
    PRDKEY INT,
    CUST_GEOKEY INT,
    SELL_GEOKEY INT,
    CSTKEY INT,
    SLRKEY INT,
    
    -- FROM ORDERITEMS TABLE (The Grain: Item Level)
    order_id VARCHAR(50),
    order_item_id INT,
    DK_shipping_limit_date INT,
    price DECIMAL(10,2), 
    freight_value DECIMAL(10,2),
    
    -- FROM ORDERS TABLE
    order_status VARCHAR(20),
    DK_order_purchase_timestamp INT,
    DK_order_approved_at INT,
    DK_order_delivered_carrier_date INT,
    DK_order_delivered_customer_date INT,
    DK_order_estimated_delivery_date INT,
    
    -- FROM PAYMENTS TABLE (Aggregated to Order Level)
    main_payment_type VARCHAR(50), 
    total_order_payment DECIMAL(10,2), 
    
    -- FROM VIEWS TABLE (Aggregated to Order Level)
    avg_review_score DECIMAL(3,2), 
    DK_latest_review_date INT,

    -- RELATIONSHIPS (Constraints)
    FOREIGN KEY(CATKEY) REFERENCES DMCategories(CATKEY),
    FOREIGN KEY(PRDKEY) REFERENCES DMProducts(PRDKEY),
    FOREIGN KEY(CUST_GEOKEY) REFERENCES DMGeolocation(GEOKEY),
    FOREIGN KEY(SELL_GEOKEY) REFERENCES DMGeolocation(GEOKEY),
    FOREIGN KEY(CSTKEY) REFERENCES DMCustomers(CSTKEY),
    FOREIGN KEY(SLRKEY) REFERENCES DMSellers(SLRKEY),
    FOREIGN KEY(DK_shipping_limit_date) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_order_purchase_timestamp) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_order_approved_at) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_order_delivered_carrier_date) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_order_delivered_customer_date) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_order_estimated_delivery_date) REFERENCES DIM_DATE(Datekey),
    FOREIGN KEY(DK_latest_review_date) REFERENCES DIM_DATE(Datekey)
);

SELECT 
    name AS Constraint_Name, 
    OBJECT_NAME(parent_object_id) AS Table_With_FK, 
    OBJECT_NAME(referenced_object_id) AS Referenced_Table
FROM sys.foreign_keys;


