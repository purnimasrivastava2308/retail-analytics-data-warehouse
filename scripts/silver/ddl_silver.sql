/*
================================================================================
                         SILVER LAYER - DDL SCRIPT
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Layer:
------
Silver Layer

Purpose:
--------
Creates the Silver layer tables used to store cleaned, standardized, and
validated data transformed from the Bronze layer.

The Silver layer acts as the data quality and transformation layer between
raw source data and the business-ready Gold layer.

Data Flow:
----------

    Source CSV Files
          |
          v
    Bronze Layer
    (Raw Data)
          |
          v
    Silver Layer
    (Cleaned & Standardized Data)
          |
          v
    Gold Layer
    (Business-Ready Data)


Silver Layer Responsibilities:
-------------------------------
- Standardize column values
- Clean leading/trailing whitespace
- Remove unwanted control characters
- Standardize categorical values
- Handle invalid or missing values
- Remove duplicate records
- Apply data quality rules
- Standardize date values
- Derive required attributes
- Preserve data warehouse load timestamps


Naming Conventions:
-------------------
- Table names use lowercase snake_case.
- Column names use lowercase snake_case.
- Source column names are retained where practical to maintain traceability.
- `dwh_create_date` is used as the data warehouse record creation timestamp.


Metadata:
---------
`dwh_create_date`
    Records when the row was inserted into the Silver layer.

    DEFAULT CURRENT_TIMESTAMP is used so the warehouse automatically records
    the insertion timestamp.


Design Principle:
-----------------
Silver tables contain cleaned and standardized data, but should remain
reasonably close to the structure of the source data.

Business-specific dimensional modeling and analytical transformations should
primarily be handled in the Gold layer.

================================================================================
*/


-- ============================================================================
-- USE SILVER DATABASE
-- ============================================================================

USE RetailAnalyticsDW_silver;


-- ============================================================================
-- CRM CUSTOMER INFORMATION
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and standardized CRM customer information.

Transformations applied during Silver loading may include:
- Trimming customer names
- Standardizing marital status
- Standardizing gender
- Removing duplicate customer records
- Handling invalid dates
- Replacing invalid values with NULL or 'n/a'
*/

DROP TABLE IF EXISTS crm_cust_info;

CREATE TABLE crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(20),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  CHAR(10),
    cst_gndr            CHAR(10),
    cst_create_date     DATE,
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- CRM PRODUCT INFORMATION
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and standardized CRM product information.

Transformations applied during Silver loading may include:
- Extracting category ID from product key
- Standardizing product line values
- Trimming product names and keys
- Handling invalid product costs
- Deriving product end dates using the next product start date
*/

DROP TABLE IF EXISTS crm_prd_info;

CREATE TABLE crm_prd_info (
    prd_id              INT,
    cat_id              VARCHAR(50),
    prd_key             VARCHAR(50),
    prd_nm              VARCHAR(150),
    prd_cost            DECIMAL(10,2),
    prd_line            CHAR(20),
    prd_start_dt        DATE,
    prd_end_dt          DATE,
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- CRM SALES DETAILS
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and validated CRM sales transaction data.

Transformations applied during Silver loading may include:
- Standardizing date values
- Validating sales amounts
- Validating quantity and price
- Handling missing or invalid values
- Ensuring sales, quantity, and price are logically consistent
*/

DROP TABLE IF EXISTS crm_sales_details;

CREATE TABLE crm_sales_details (
    sls_ord_num         VARCHAR(20),
    sls_prd_key         VARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           DECIMAL(10,2),
    sls_quantity        INT,
    sls_price           DECIMAL(10,2),
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP CUSTOMER INFORMATION
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and standardized ERP customer demographic information.

Transformations applied during Silver loading may include:
- Cleaning customer identifiers
- Standardizing gender values
- Removing carriage-return and other unwanted characters
- Handling invalid birth dates
- Converting future birth dates to NULL
*/

DROP TABLE IF EXISTS erp_cust_az12;

CREATE TABLE erp_cust_az12 (
    cid                 VARCHAR(30),
    bdate               DATE,
    gen                 VARCHAR(20),
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP CUSTOMER LOCATION
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and standardized ERP customer country/location information.

Transformations applied during Silver loading may include:
- Standardizing customer identifiers
- Removing unwanted characters
- Standardizing country names
- Handling blank or invalid country values
*/

DROP TABLE IF EXISTS erp_loc_a101;

CREATE TABLE erp_loc_a101 (
    cid                 VARCHAR(30),
    cntry               VARCHAR(50),
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- ERP PRODUCT CATEGORY
-- ============================================================================
/*
Purpose:
--------
Stores cleaned and standardized ERP product category information.

Transformations applied during Silver loading may include:
- Standardizing category names
- Standardizing subcategory names
- Cleaning maintenance indicators
- Handling missing or invalid category attributes
*/

DROP TABLE IF EXISTS erp_cat_g1v2;

CREATE TABLE erp_cat_g1v2 (
    id                  VARCHAR(20),
    cat                 VARCHAR(100),
    subcat              VARCHAR(100),
    maintenance         VARCHAR(10),
    dwh_create_date     DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- END OF SILVER DDL
-- ============================================================================
/*
The tables created by this script are populated by the Silver layer load
scripts.

Recommended execution order:

    1. ddl_silver.sql
    2. load_silver.sql

The Silver layer should receive data from the Bronze layer and should not
directly depend on the original CSV source files.
*/
