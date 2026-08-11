/*
================================================================================
                         BRONZE LAYER - LOAD SCRIPT
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Loads raw CRM and ERP CSV files into Bronze layer tables.

Features:
---------
✓ Loads raw CRM and ERP CSV files
✓ Truncates existing Bronze data before loading
✓ Validates loaded record counts

Execution Flow:
---------------

CSV Files
    |
    ↓
Bronze Layer Tables
    |
    ↓
Load Validation

Note:
-----
If any SQL error occurs, MySQL Workbench stops execution and displays
the corresponding error message and error code.

================================================================================
*/


-- ============================================================================
-- CRM PRODUCT DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE crm_prd_info;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- CRM CUSTOMER DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE crm_cust_info;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- CRM SALES DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE crm_sales_details;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP CUSTOMER DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE erp_cust_az12;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP LOCATION DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE erp_loc_a101;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- ERP CATEGORY DATA LOAD
-- ============================================================================

USE RetailAnalyticsDW_bronze;

TRUNCATE TABLE erp_cat_g1v2;

LOAD DATA LOCAL INFILE
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE erp_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================================
-- LOAD VALIDATION
-- ============================================================================

SELECT
    'crm_prd_info' AS table_name,
    COUNT(*) AS records_loaded
FROM crm_prd_info

UNION ALL

SELECT
    'crm_cust_info',
    COUNT(*)
FROM crm_cust_info

UNION ALL

SELECT
    'crm_sales_details',
    COUNT(*)
FROM crm_sales_details

UNION ALL

SELECT
    'erp_cust_az12',
    COUNT(*)
FROM erp_cust_az12

UNION ALL

SELECT
    'erp_loc_a101',
    COUNT(*)
FROM erp_loc_a101

UNION ALL

SELECT
    'erp_cat_g1v2',
    COUNT(*)
FROM erp_cat_g1v2;
