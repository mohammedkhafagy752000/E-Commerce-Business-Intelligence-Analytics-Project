use P_Ecommerce;

-- 1. EXTRACT CATEGORIES DATA FROM CSV 
BULK INSERT Categories 
FROM 'D:\ecommerce pro\Dataset\Categories.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
); 
-- 2. EXTRACT PRODUCTS DATA FROM CSV 
BULK INSERT Products 
FROM 'D:\ecommerce pro\Dataset\Products.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
); 
-- 3. EXTRACT GEOLOCATION DATA FROM CSV FILE
BULK INSERT Geolocation 
from 'D:\ecommerce pro\Dataset\Geolocation.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);    --> ERROR ZIP CODE DUBLICATED THIS MEANIG CAN'T USE AS PRIMARY KEY BUT THE SOLUATION FOLLOW DOWN
-- 3.1 CRATE STAGING TABLE TO LOAD DATA IN THERE CURRENT STATUS
CREATE TABLE #STATGING_Geolocation
(
geolocation_zip_code_prefix INT,
geolocation_lat DECIMAL(9,6),
geolocation_lng DECIMAL(9,6),
geolocation_city varchar(50),
geolocation_state varchar(20)
);
-- 3.2 EXTRACT GEOLOCATION DATA TO STATGING TABLE
BULK INSERT #STATGING_Geolocation 
from 'D:\ecommerce pro\Dataset\Geolocation.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);
 --3.3 EXTRACT DATA FROM STATGING TABLE TO GEOLOCATION TABLE 
 INSERT INTO Geolocation
 (
 geolocation_zip_code_prefix ,
 geolocation_lat ,
 geolocation_lng ,
 geolocation_city ,
 geolocation_state
 )
 SELECT geolocation_zip_code_prefix ,
 AVG(geolocation_lat),
 AVG(geolocation_lng),
 MAX(geolocation_city),
 MAX(geolocation_state)
 FROM #STATGING_Geolocation
 GROUP BY geolocation_zip_code_prefix;

 --4. EXTRACT Customers data from CSV
 BULK INSERT Customers 
 from 'D:\ecommerce pro\Dataset\Customers.CSV'
 with(
 Format='CSV',
 FIRSTROW=2,
 FIELDTERMINATOR =',',
 ROWTERMINATOR='0x0a',
 TABLOCK
 );  --> ERROR DUBLICATED IN  UNIQUE CUSTOMERS IDS THE SOLOATION FOLLOW DOWN

 -- 4.1 CREATE CUSTOMERS STAGING TABLE
 CREATE TABLE #STAGING_CUSTOMERS 
 (
 customer_id varchar (50) ,
 customer_unique_id varchar(50) ,
 customer_zip_code_prefix int,
 customer_city varchar(50),
 customer_state varchar(10)
 );
 --4.2 INSERT CUSTOMERS DATA 
BULK INSERT #STAGING_CUSTOMERS 
from 'D:\ecommerce pro\Dataset\Customers.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);
--4.3 INSERT INTO CUSTOMERS TABLE FROM STATGING TABLE 
INSERT INTO Customers
(
 customer_id ,
 customer_unique_id ,
 customer_zip_code_prefix,
 customer_city,
 customer_state

)
SELECT customer_id ,
 customer_unique_id ,
 customer_zip_code_prefix,
 customer_city,
 customer_state
 FROM
 ( SELECT *, ROW_NUMBER() OVER ( PARTITION BY customer_unique_id ORDER BY Customer_id) as rn from #STAGING_CUSTOMERS)t
  where t.rn=1;  --> ERROR SOME CUSTOMERS HAV'T ZIPE CODE FOLLOWING THE SOLUATION

  INSERT INTO Geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
  VALUES (9999, 'Unknown City', 'NA');
   -- UPDATE STAGING CUSTOMERS TABLE
  UPDATE S
  SET S.customer_zip_code_prefix = 9999
  FROM #STAGING_CUSTOMERS S
  LEFT JOIN Geolocation G ON S.customer_zip_code_prefix = G.geolocation_zip_code_prefix
  WHERE G.geolocation_zip_code_prefix IS NULL;
 -- check count of customers that use the substitute value 9999.
  Select count (*) from Customers
  where customer_zip_code_prefix = 9999;  --> This time the problem is not found

  --. EXTRACT sellers data from CSV
 BULK INSERT sellers 
 from 'D:\ecommerce pro\Dataset\sellers.CSV'
 with(
 Format='CSV',
 FIRSTROW=2,
 FIELDTERMINATOR =',',
 ROWTERMINATOR='0x0a',
 TABLOCK
 );  
 -- 6. EXTRACT ORDERS DATA FROM CSVs
BULK INSERT Orders 
from 'D:\ecommerce pro\Dataset\Orders.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);
-- 7. EXTRACT Orderitems DATA FROM CSVs
BULK INSERT Orderitems 
from 'D:\ecommerce pro\Dataset\Order items.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);
-- 8. EXTRACT Orderpayments DATA FROM CSVs
BULK INSERT Orderpayments 
from 'D:\ecommerce pro\Dataset\Order payments.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
);
-- 9. EXTRACT Reviews DATA FROM CSVs
BULK INSERT Reviews 
from 'D:\ecommerce pro\Dataset\Reviews.CSV'
with(
Format='CSV',
FIRSTROW=2,
FIELDTERMINATOR =',',
ROWTERMINATOR='0x0a',
TABLOCK
); --> because the reviews details in un uderstood by sql engin
--9.1 create statging table to EXTRACT FROM CSVs
CREATE TABLE #STAGING_REVIEWS (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title NVARCHAR(MAX),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);
--9.2 EXTRACT REVIEWS DATA FROM REVIEWS TABLE INTO #STAGING
BULK INSERT #STAGING_REVIEWS
FROM 'D:\ecommerce pro\Dataset\Reviews.CSV'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n', 
    TABLOCK
);
-- 9.3 EXTRACT REVIEWS DATA FROM STAGING TABLE
INSERT INTO Reviews (review_id ,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date ,
    review_answer_timestamp)
    SELECT review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date ,
    review_answer_timestamp
    FROM ( SELECT *, ROW_NUMBER() OVER( PARTITION BY review_id ORDER BY  review_creation_date) AS RN
        FROM #STAGING_REVIEWS) AS T
        WHERE RN=1;
        