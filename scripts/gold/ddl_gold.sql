/*
================================================================================
                         GOLD LAYER - DATA MART
================================================================================

Project:
--------
Retail Analytics Data Warehouse


Purpose:
--------
Creates business-ready dimension and fact tables from the Silver layer.

Tables:
-------
- dim_customers : Customer dimension enriched with ERP demographic and
                  location data.

- dim_products  : Current product dimension enriched with category
                  and maintenance information.

- fact_sales    : Sales fact combining transactional data with customer
                  and product surrogate keys.


Model:
------
                    dim_customers
                         |
                         |
                         v
                     fact_sales
                         ^
                         |
                         |
                    dim_products


Transformations:
----------------
- Generates surrogate keys for customer and product dimensions.
- Enriches customer data with ERP demographic and location information.
- Enriches product data with ERP category information.
- Includes only the current version of each product.
- Resolves customer and product relationships using business keys.
- Creates a business-ready sales fact table using Gold surrogate keys.


Notes:
------
- Gold objects are physical tables rather than views.
- Surrogate keys are generated using ROW_NUMBER().
- Customer and product dimensions are built from Silver layer data.
- fact_sales references customer_key and product_key from Gold dimensions.
- Gold tables are intended for analytics, reporting, Tableau, and ML workloads.

================================================================================
*/


-- ============================================================================
-- CUSTOMER DIMENSION
-- ============================================================================

USE retailanalyticsdw_silver;

DROP TABLE IF EXISTS retailanalyticsdw_gold.dim_customers;

CREATE TABLE retailanalyticsdw_gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM crm_cust_info ci
LEFT JOIN erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- ============================================================================
-- PRODUCT DIMENSION
-- ============================================================================

USE retailanalyticsdw_silver;

DROP TABLE IF EXISTS retailanalyticsdw_gold.dim_products;

CREATE TABLE retailanalyticsdw_gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM retailanalyticsdw_silver.crm_prd_info pn
LEFT JOIN retailanalyticsdw_silver.erp_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;


-- ============================================================================
-- SALES FACT
-- ============================================================================

USE retailanalyticsdw_silver;

DROP TABLE IF EXISTS retailanalyticsdw_gold.fact_sales;

CREATE TABLE retailanalyticsdw_gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM retailanalyticsdw_silver.crm_sales_details sd
LEFT JOIN retailanalyticsdw_gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN retailanalyticsdw_gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
