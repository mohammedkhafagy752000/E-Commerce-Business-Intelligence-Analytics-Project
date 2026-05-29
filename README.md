# 📊 E-Commerce Business Intelligence Analytics Project

An end-to-end Business Intelligence project focused on transforming raw e-commerce transactional data into actionable business insights using SQL Server and Power BI.

The project simulates a real-world BI workflow including:

* Data Extraction & ETL
* Data Cleaning & Validation
* Data Warehouse Modeling
* Star Schema Design
* KPI Development
* Interactive Business Intelligence Reporting

---

# 📌 Project Overview

This project was designed to analyze large-scale e-commerce operations and support data-driven business decisions through a complete BI pipeline.

The workflow started from raw CSV datasets and progressed through multiple stages including:

* SQL-based ETL processing
* Data quality validation
* Data warehouse modeling
* KPI analysis
* Interactive dashboard reporting

The final result was a fully integrated BI system capable of delivering operational and strategic insights across sales, customers, payments, geography, and product categories.

---

# 🛠 Tech Stack

| Technology  | Purpose                   |
| ----------- | ------------------------- |
| SQL Server  | ETL & Data Warehousing    |
| T-SQL       | Data Cleaning & Analytics |
| Power BI    | Dashboard Development     |
| DAX         | KPI Calculations          |
| Excel / CSV | Raw Data Sources          |

---

# ⚙️ Data Engineering & ETL Process

The project involved handling complex retail datasets using advanced SQL-based ETL workflows.

## Key ETL Operations

### 📥 Data Extraction

* Imported multiple CSV datasets using `BULK INSERT`
* Loaded customers, products, orders, payments, reviews, and geolocation datasets into SQL Server

### 🧹 Data Cleaning & Validation

Several real-world data quality issues were resolved:

#### Duplicate Zip Codes

* Created staging tables
* Applied `GROUP BY` with geographic averaging using `AVG(latitude)` and `AVG(longitude)`

#### Duplicate Customers

* Used `ROW_NUMBER()` with `PARTITION BY` to identify and remove duplicate customer records

#### Missing Values

* Replaced missing ZIP codes with default placeholder values (`9999`)
* Assigned unknown geographic locations to preserve relational integrity

#### Customer Reviews

* Built staging tables using `NVARCHAR(MAX)` to handle large review text safely before loading into production tables

---

# 🏗 Data Warehouse Design

A professional Star Schema model was implemented to optimize analytical performance inside Power BI.

## Fact Table

### `FACTOrders`

Contains:

* Sales transactions
* Quantities
* Payment values
* Order metrics

## Dimension Tables

* `DMCustomers`
* `DMProducts`
* `DMCategories`
* `DIM_DATE`
* `DMSellers`
* `DMGeolocation`

This architecture significantly improved query performance and dashboard scalability.

---

# 📈 KPI Development

Business KPIs were developed using DAX measures inside Power BI.

## Key Metrics

| KPI                  | Value   |
| -------------------- | ------- |
| Total Sales          | $7.4M   |
| Total Orders         | 54K     |
| Total Payments       | $8.6M   |
| Average Review Score | 4.0 / 5 |
| Sales Growth         | +28.5%  |
| Orders Growth        | +29.1%  |
| Payments Growth      | +29.7%  |

The analysis also compared actual sales performance against a strategic sales target of **$10M**.

---

# 📊 Business Insights

## 🏆 Top Product Categories

* Health & Beauty generated **25.26%** of total sales
* Watches & Gifts contributed **23.19%**

Together, both categories represented the major revenue drivers for the platform.

---

## 🌍 Geographic Analysis

* São Paulo (SP) dominated both order volume and payment activity
* Geographic analysis revealed strong regional concentration of customer demand

---

## 📅 Time-Series Analysis

Sales and payments remained relatively stable from January through August.

A noticeable decline appeared during September, indicating either:

* Potential seasonality effects
* Missing operational data
* Market demand fluctuations

---

# 📊 Interactive Dashboard

The Power BI dashboard included:

* KPI Cards
* Sales Trend Analysis
* Geographic Visualizations
* Product Category Performance
* Payment Analysis
* Customer Satisfaction Metrics
* Time-Series Insights

The dashboard was designed to support strategic business decisions through interactive exploration.

---

# 📂 Project Structure

```bash
E-Commerce-Business-Intelligence-Analytics-Project/
│
├── SQL_Scripts/
│   ├── 001_OLTP_CREATION.sql
│   ├── 002_EXTRACT.sql
│   ├── 003_DATAWAREHOUSE CREATION.sql
│   └── 004_EXTRACT_FROM_OLTP TO_DW.sql
│
├── Datasets/
│   ├── sample_Categories.csv
│   ├── sample_Customers.csv
│   ├── sample_Geolocation.csv
│   ├── sample_Order Items.csv
│   ├── sample_Order Payments.csv
│   ├── sample_Orders.csv
│   ├── sample_Products.csv
│   ├── sample_Reviews.csv
│   └── sample_Sellers.csv
│
├── Ecommerce_Project_SQL_Power_BI.pbix
└── README.md
```

---

# 🚀 Key Skills Demonstrated

* SQL ETL Development
* Data Warehouse Design
* Star Schema Modeling
* Data Cleaning & Validation
* Advanced SQL Analytics
* Power BI Dashboarding
* DAX Calculations
* Business Intelligence Reporting
* Data Storytelling

---

# 🔮 Future Improvements

* Customer Segmentation
* Predictive Sales Forecasting
* Inventory Optimization
* Real-Time Data Pipelines
* Cloud Data Warehouse Integration

---

# 📬 Author

**Mohamed Khafagy**
Data Analytics & Business Intelligence Enthusiast

LinkedIn:
https://www.linkedin.com/in/mohammed-khafagy-7559aa272
