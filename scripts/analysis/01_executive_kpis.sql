/*
================================================================================
                         EXECUTIVE KPI ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Provides high-level business KPIs for executive reporting.

Metrics:
--------
- Total revenue
- Total orders
- Total quantity sold
- Average order value
- Total profit
- Profit margin

================================================================================
*/

USE RetailAnalyticsDW_gold;

SELECT
    SUM(fc.sales_amount) AS total_revenue,
    COUNT(DISTINCT fc.order_number) AS total_orders,
    SUM(fc.quantity) AS total_quantity,
    ROUND(
        SUM(fc.sales_amount) / COUNT(DISTINCT fc.order_number),
        2
    ) AS average_order_value,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity),
        2
    ) AS total_profit,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity)
        / NULLIF(SUM(fc.sales_amount), 0) * 100,
        2
    ) AS profit_margin
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key;
