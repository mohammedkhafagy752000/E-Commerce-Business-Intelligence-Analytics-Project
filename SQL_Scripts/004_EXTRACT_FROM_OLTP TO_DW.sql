--1. EXTRACT FROM OLTP INTO DIM CATEGORIES 
INSERT INTO DMCategories(product_category_name,product_category_name_english)
SELECT product_category_name,product_category_name_english
FROM P_Ecommerce.dbo.Categories;
--2. EXTRACT FROM OLTP INTO DIM PRODUCTS 
INSERT INTO DMPRODUCTS(product_id ,
product_category_name ,
product_name_length,
product_description_length ,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm)
SELECT product_id ,
product_category_name ,
product_name_length,
product_description_length ,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
FROM P_Ecommerce.dbo.PRODUCTS;
--3. EXTRACT FROM OLTP INTO DIM Geolocation 
INSERT INTO DMGeolocation(geolocation_zip_code_prefix ,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state)
SELECT geolocation_zip_code_prefix ,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state
FROM P_Ecommerce.dbo.Geolocation;
--4. EXTRACT FROM OLTP INTO DIM Customers 
INSERT INTO DMCustomers(customer_id,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state)
SELECT customer_id,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state
FROM P_Ecommerce.dbo.Customers;
--5. EXTRACT FROM OLTP INTO DIM Sellers 
INSERT INTO DMSellers(seller_id ,
seller_zip_code_prefix,
seller_city,
seller_state)
SELECT seller_id ,
seller_zip_code_prefix,
seller_city,
seller_state
FROM P_Ecommerce.dbo.Sellers;
--6. BUILD DIM DATE 
DECLARE @STARTDATE DATE ='2015-01-01'; 
DECLARE @ENDDATE DATE ='2025-12-31';

WHILE @STARTDATE<=@ENDDATE
BEGIN
INSERT INTO DIM_DATE(
    DateKey,       
    FullDate,        
    Year ,             
    Quarter ,         
    Month,           
    MonthName ,         
    Day ,              
    DayName ,           
    DayOfWeek ,        
    IsWeekend 
    )
    SELECT CAST (FORMAT(@STARTDATE,'yyyyMMdd')AS INT),
    @STARTDATE,
    YEAR(@STARTDATE),
    DATEPART(QUARTER,@STARTDATE),
    MONTH (@STARTDATE),
    DATENAME(MONTH,@STARTDATE),
    DAY(@STARTDATE),
    DATENAME(WEEKDAY,@STARTDATE),
    DATEPART(WEEKDAY,@STARTDATE),
    CASE WHEN DATENAME(WEEKDAY,@STARTDATE) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
    SET @STARTDATE = DATEADD(DAY, 1, @STARTDATE); 
    END;
    -- TO AVOID REDUNDANCY WE WEILL AGGREGATE PAYMENTS AND REVIEWS DATA
    -- Aggregated Payments
WITH AggregatedPayments AS (
    SELECT order_id, 
           SUM(payment_value) as TotalOrderPayment,
           MAX(payment_type) as MainPaymentType
    FROM P_Ecommerce.dbo.Orderpayments
    GROUP BY order_id
),
-- Aggregated Reviews
AggregatedReviews AS (
    SELECT order_id, 
           AVG(CAST(review_score AS DECIMAL(10,2))) as AvgReviewScore,
           MAX(review_creation_date) as LatestReviewDate
    FROM P_Ecommerce.dbo.Reviews
    GROUP BY order_id
)
    -- EXTRACT FROM OLTP INTO THE MASTER TABLE FACT ORDRS
    INSERT INTO FACTOrders(CATKEY,
    PRDKEY,
    CUST_GEOKEY ,
    SELL_GEOKEY ,
    CSTKEY ,
    SLRKEY ,
    -- FROM ORDERITEMS TABLE
    order_id ,
    order_item_id,
    DK_shipping_limit_date,
    price,
    freight_value,
    -- FROM ORDERS TABLE
    order_status,
    DK_order_purchase_timestamp,
    DK_order_approved_at,
    DK_order_delivered_carrier_date,
    DK_order_delivered_customer_date,
    DK_order_estimated_delivery_date,
    -- FROM PAYMENTS TABLE 
     main_payment_type,
     total_order_payment,
    --FROM VIEWS TABLE
    avg_review_score,
    DK_latest_review_date)
    SELECT CATKEY,
    PRDKEY,
    DMG.GEOKEY ,
    DMG2.GEOKEY ,
    CSTKEY ,
    SLRKEY ,
    -- FROM ORDERITEMS TABLE
    ORIT.order_id ,
    ORIT.order_item_id,
    DD.DateKey,
    ORIT.price,
    ORIT.freight_value,
    -- FROM ORDERS TABLE
    order_status,
    DDOPT.DateKey,
    DDOAA.DateKey,
    DDODC.DateKey,
    DDODCT.DateKey,
    DDOED.DateKey,
    -- FROM PAYMENTS TABLE 
    AGP.MainPaymentType,
    AGP.TotalOrderPayment ,
    --FROM VIEWS TABLE
    AGR.AvgReviewScore,
    DDRC.DateKey
    FROM P_Ecommerce.dbo.Orderitems ORIT
    LEFT JOIN DMPRODUCTS DMP ON ORIT.product_id=DMP.product_id
    LEFT JOIN DMCategories DMC ON DMP.product_category_name=DMC.product_category_name
    LEFT JOIN P_Ecommerce.dbo.Orders ORD ON ORIT.order_id=ORD.order_id
    LEFT JOIN DMCustomers DMCT ON ORD.customer_id=DMCT.customer_id AND DMCT.IS_CURRENT=1
    LEFT JOIN DMGeolocation DMG ON DMCT.customer_zip_code_prefix=DMG.geolocation_zip_code_prefix
    LEFT JOIN DMSellers DMS ON ORIT.seller_id=DMS.seller_id AND DMS.IS_CURRENT=1
    LEFT JOIN DMGeolocation DMG2 ON DMS.seller_zip_code_prefix=DMG2.geolocation_zip_code_prefix
    LEFT JOIN AggregatedPayments AGP ON ORD.order_id=AGP.order_id
    LEFT JOIN AggregatedReviews AGR ON ORD.order_id=AGR.order_id
    LEFT JOIN DIM_DATE DD ON CAST(ORIT.shipping_limit_date AS date)= DD.FullDate
    LEFT JOIN DIM_DATE DDOPT ON CAST(ORD.order_purchase_timestamp AS date)= DDOPT.FullDate
    LEFT JOIN DIM_DATE DDOAA ON CAST(ORD.order_approved_at AS date)= DDOAA.FullDate
    LEFT JOIN DIM_DATE DDODCT ON CAST(ORD.order_delivered_customer_date AS date)= DDODCT.FullDate
    LEFT JOIN DIM_DATE DDOED ON CAST(ORD.order_estimated_delivery_date AS date)=DDOED.FullDate
    LEFT JOIN DIM_DATE DDODC ON CAST(ORD.order_delivered_carrier_date AS date)= DDODC.FullDate
    LEFT JOIN DIM_DATE DDRC ON CAST(AGR.LatestReviewDate AS date)=DDRC.FullDate;
    SELECT COUNT (order_item_id) FROM FACTOrders; --->> DONE
