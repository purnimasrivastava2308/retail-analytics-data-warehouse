/*
================================================================================
                         BRONZE LAYER - DDL SCRIPT
================================================================================

Project:
-------
Retail Analytics Data Warehouse

Purpose:
--------
This script creates the Bronze layer tables used to store raw data
ingested from CRM and ERP source systems.

The Bronze layer follows the Medallion Architecture approach:

    Source Systems
          |
          ↓
      Bronze Layer
          |
          ↓
      Silver Layer
          |
          ↓
       Gold Layer


Layer Description:
------------------
Bronze Layer:
- Stores raw source data with minimal transformations.
- Maintains data exactly as received from source systems.
- Acts as the historical landing zone for downstream processing.


Source Systems:
---------------
1. CRM System
   - Customer information
   - Product information
   - Sales transactions

2. ERP System
   - Customer demographic data
   - Customer location data
   - Product category information


Tables Created:
---------------

CRM Tables:
-----------
1. crm_cust_info
   Stores raw customer master data.

2. crm_prd_info
   Stores raw product master data.

3. crm_sales_details
   Stores raw sales transaction data.


ERP Tables:
-----------
4. erp_cust_az12
   Stores customer demographic information.

5. erp_loc_a101
   Stores customer location information.

6. erp_cat_g1v2
   Stores product category and maintenance information.


Execution:
----------
Run this script before loading data into the Bronze layer.

Example:
    1. Execute init_database.sql
    2. Execute ddl_bronze.sql
    3. Execute load_bronze.sql


================================================================================
*/


USE RetailAnalyticsDW_bronze;


-- =============================================================================
-- CRM CUSTOMER TABLE
-- =============================================================================
-- Purpose:
-- Stores raw customer information received from CRM source system.
-- =============================================================================

DROP TABLE IF EXISTS crm_cust_info;

CREATE TABLE crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(20),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status CHAR(10),
    cst_gndr           CHAR(10),
    cst_create_date    VARCHAR(20)
);



-- =============================================================================
-- CRM PRODUCT TABLE
-- =============================================================================
-- Purpose:
-- Stores raw product master data received from CRM source system.
-- =============================================================================

DROP TABLE IF EXISTS crm_prd_info;

CREATE TABLE crm_prd_info (
    prd_id         INT,
    prd_key        VARCHAR(50),
    prd_nm         VARCHAR(150),
    prd_cost       DECIMAL(10,2),
    prd_line       CHAR(20),
    prd_start_dt   DATE,
    prd_end_dt     DATE
);



-- =============================================================================
-- CRM SALES TABLE
-- =============================================================================
-- Purpose:
-- Stores raw sales transaction records.
-- =============================================================================

DROP TABLE IF EXISTS crm_sales_details;

CREATE TABLE crm_sales_details (
    sls_ord_num     VARCHAR(20),
    sls_prd_key     VARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    INT,
    sls_ship_dt     INT,
    sls_due_dt      INT,
    sls_sales       DECIMAL(10,2),
    sls_quantity    INT,
    sls_price       DECIMAL(10,2)
);



-- =============================================================================
-- ERP CUSTOMER TABLE
-- =============================================================================
-- Purpose:
-- Stores additional customer attributes from ERP system.
-- =============================================================================

DROP TABLE IF EXISTS erp_cust_az12;

CREATE TABLE erp_cust_az12 (
    cid     VARCHAR(30),
    bdate   DATE,
    gen     VARCHAR(20)
);



-- =============================================================================
-- ERP LOCATION TABLE
-- =============================================================================
-- Purpose:
-- Stores customer country/location information.
-- =============================================================================

DROP TABLE IF EXISTS erp_loc_a101;

CREATE TABLE erp_loc_a101 (
    cid     VARCHAR(30),
    cntry   VARCHAR(50)
);



-- =============================================================================
-- ERP CATEGORY TABLE
-- =============================================================================
-- Purpose:
-- Stores product category hierarchy and maintenance information.
-- =============================================================================

DROP TABLE IF EXISTS erp_cat_g1v2;

CREATE TABLE erp_cat_g1v2 (
    id            VARCHAR(20),
    cat           VARCHAR(100),
    subcat        VARCHAR(100),
    maintenance   VARCHAR(10)
);



-- =============================================================================
-- Validation
-- =============================================================================

SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'RetailAnalyticsDW_bronze';
