-- ============================================================
-- Silver Layer Indexes
-- ============================================================

USE retailanalyticsdw_silver;


-- ============================================================
-- CRM Customer
-- ============================================================

CREATE INDEX idx_crm_cust_info_customer_key
ON crm_cust_info (customer_key);


-- ============================================================
-- CRM Product
-- ============================================================

CREATE INDEX idx_crm_prd_info_product_key
ON crm_prd_info (product_key);

CREATE INDEX idx_crm_prd_info_category_id
ON crm_prd_info (category_id);


-- ============================================================
-- CRM Sales Details
-- ============================================================

CREATE INDEX idx_crm_sales_details_product_key
ON crm_sales_details (product_key);

CREATE INDEX idx_crm_sales_details_customer_id
ON crm_sales_details (customer_id);

CREATE INDEX idx_crm_sales_details_order_date
ON crm_sales_details (order_date);


-- ============================================================
-- ERP Category
-- ============================================================

CREATE INDEX idx_erp_cat_g1v2_category_id
ON erp_cat_g1v2 (category_id);


-- ============================================================
-- ERP Customer
-- ============================================================

CREATE INDEX idx_erp_cust_az12_customer_id
ON erp_cust_az12 (customer_id);


-- ============================================================
-- ERP Location
-- ============================================================

CREATE INDEX idx_erp_loc_a101_customer_id
ON erp_loc_a101 (customer_id);
