-- OLTP DATABASE CREATION
create database P_Ecommerce ;
use P_Ecommerce;

-- 1. CATEGORIES TABLE CREATION
CREATE TABLE Categories
(
product_category_name VARCHAR(50) PRIMARY KEY,
product_category_name_english VARCHAR (50)
);

-- 2. PRODUCTS TABLE CREATION
CREATE TABLE PRODUCTS 
(
product_id VARCHAR(50) PRIMARY KEY NOT NULL,
product_category_name VARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g DECIMAL(10,2),
product_length_cm DECIMAL(10,2),
product_height_cm DECIMAL(10,2),
product_width_cm DECIMAL(10,2),
FOREIGN KEY(product_category_name) REFERENCES Categories(product_category_name)
);

-- 3. GEOLOCATION TABLE CREATION
CREATE TABLE Geolocation 
(
geolocation_zip_code_prefix int primary key,
geolocation_lat DECIMAL(9,6),
geolocation_lng DECIMAL(9,6),
geolocation_city varchar(50),
geolocation_state varchar(20)
);
-- 4. CUSTOMERS TABLE CREATION 
Create table Customers 
(
customer_id varchar (50) primary key,
customer_unique_id varchar(50) unique,
customer_zip_code_prefix int,
customer_city varchar(50),
customer_state varchar(10),
FOREIGN KEY (customer_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix)
);
-- 5. SELLERS TABLE CREATION
CREATE TABLE Sellers 
(
seller_id varchar(50) primary key,
seller_zip_code_prefix int,
seller_city varchar (50),
seller_state varchar(20),
FOREIGN KEY (seller_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix)
);
-- 6. ORDERS TABLE CREATION
CREATE TABLE Orders 
(
order_id varchar(50) primary key,
customer_id varchar(50),
order_status VARCHAR(20),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATE,
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 7. ORDERITEMS TABLE CREATION
CREATE TABLE Orderitems 
(
order_id varchar(50),
order_item_id INT,
product_id varchar(50),
seller_id VARCHAR (50),
shipping_limit_date DATETIME,
price decimal(10,2),
freight_value decimal(10,2),
FOREIGN KEY (order_id) REFERENCES Orders(order_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id),
FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id)
);

-- 8. ORDERPAYMENTS TABLE CREATION
CREATE TABLE Orderpayments
(
order_id varchar(50),
payment_sequential INT,
payment_type varchar(50),
payment_installments INT,
payment_value decimal(10,2),
FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
-- 9. REVIEWS TABLE CREATION
CREATE TABLE Reviews 
(
review_id varchar(50) primary key,
order_id varchar(50),
review_score INT,
review_comment_title VARCHAR(200),
review_comment_message VARCHAR(1000),
review_creation_date DATE,
review_answer_timestamp DATE,
FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);