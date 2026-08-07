/*
================================================================================
                         BRONZE LAYER - LOAD SCRIPT
================================================================================

Project:
-------
Retail Analytics Data Warehouse


Purpose:
--------
Loads raw CRM and ERP CSV files into Bronze layer tables.


Features:
---------
✓ Execution start and end time tracking
✓ Individual table load timing
✓ Total execution duration
✓ Progress monitoring messages
✓ Data truncation before loading
✓ Record count validation
✓ Load summary report


Execution Flow:
---------------

CSV Files
    |
    ↓
Bronze Layer Tables
    |
    ↓
Validation Report


Note:
-----
If any SQL error occurs:
- MySQL Workbench stops execution.
- Error message and error code are displayed.

================================================================================
*/


USE RetailAnalyticsDW_bronze;


-- ============================================================================
-- INITIALIZE EXECUTION VARIABLES
-- ============================================================================

SET @pipeline_start_time = NOW();


SELECT 
    '================================================' AS message
UNION ALL
SELECT 
    CONCAT(
        'Bronze Load Started: ',
        @pipeline_start_time
    );



-- ============================================================================
-- CRM PRODUCT DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading crm_prd_info...' AS message;

TRUNCATE TABLE crm_prd_info;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'crm_prd_info' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM crm_prd_info;


-- ============================================================================
-- CRM CUSTOMER DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading crm_cust_info...' AS message;

TRUNCATE TABLE crm_cust_info;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'crm_cust_info' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM crm_cust_info;


-- ============================================================================
-- CRM SALES DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading crm_sales_details...' AS message;

TRUNCATE TABLE crm_sales_details;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'crm_sales_details' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM crm_sales_details;


-- ============================================================================
-- ERP CUSTOMER DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading erp_cust_az12...' AS message;

TRUNCATE TABLE erp_cust_az12;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'erp_cust_az12' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM erp_cust_az12;


-- ============================================================================
-- ERP LOCATION DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading erp_loc_a101...' AS message;

TRUNCATE TABLE erp_loc_a101;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'erp_loc_a101' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM erp_loc_a101;


-- ============================================================================
-- ERP CATEGORY DATA LOAD
-- ============================================================================

SET @table_start_time = NOW();

SELECT 'Loading erp_cat_g1v2...' AS message;

TRUNCATE TABLE erp_cat_g1v2;
LOAD DATA LOCAL INFILE 
'C:/Users/Purnima Srivastava/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE erp_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @table_end_time = NOW();

SELECT 
    'erp_cat_g1v2' AS table_name,
    COUNT(*) AS records_loaded,
    TIMESTAMPDIFF(
        SECOND,
        @table_start_time,
        @table_end_time
    ) AS load_time_seconds
FROM erp_cat_g1v2;


-- ============================================================================
-- FINAL EXECUTION SUMMARY
-- ============================================================================

SET @pipeline_end_time = NOW();

SELECT 
    '================================================' AS message
UNION ALL

SELECT
    CONCAT(
        'Bronze Load Completed: ',
        @pipeline_end_time
    )
UNION ALL
SELECT
    CONCAT(
        'Total Load Time: ',
        TIMESTAMPDIFF(
            SECOND,
            @pipeline_start_time,
            @pipeline_end_time
        ),
        ' seconds'
    )
UNION ALL
SELECT
    CONCAT(
        'Total Load Time: ',
        ROUND(
            TIMESTAMPDIFF(
                SECOND,
                @pipeline_start_time,
                @pipeline_end_time
            ) / 60,
            2
        ),
        ' minutes'
    );
