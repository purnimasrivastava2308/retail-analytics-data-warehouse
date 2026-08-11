-- ============================================================
-- Gold Layer Indexes
-- ============================================================

USE retailanalyticsdw_gold;


-- ============================================================
-- Dimension Table Primary Keys
-- ============================================================

ALTER TABLE dim_customers
ADD PRIMARY KEY (customer_key);

ALTER TABLE dim_products
ADD PRIMARY KEY (product_key);


-- ============================================================
-- Fact Table Indexes
-- ============================================================

CREATE INDEX idx_fact_sales_order_number
ON fact_sales (order_number);

CREATE INDEX idx_fact_sales_order_year
ON fact_sales ((YEAR(order_date)));


-- ============================================================
-- Dimension Table Indexes
-- ============================================================

CREATE INDEX idx_dim_customers_customer_id
ON dim_customers (customer_id);

CREATE INDEX idx_dim_products_product_name
ON dim_products (product_name);
