/*
================================================================================
                           SALES TREND ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Analyzes revenue, profit, and quantity trends over time.

Analysis:
---------
- Monthly sales performance
- Monthly revenue by calendar month
- Average monthly revenue by month

================================================================================
*/

USE RetailAnalyticsDW_gold;


-- Monthly sales performance

SELECT
    YEAR(fc.order_date) AS year,
    MONTH(fc.order_date) AS month,
    SUM(fc.sales_amount) AS monthly_revenue,
    SUM((fc.price - dp.cost) * fc.quantity) AS monthly_profit,
    SUM(fc.quantity) AS monthly_quantity
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
WHERE fc.order_date IS NOT NULL
GROUP BY
    YEAR(fc.order_date),
    MONTH(fc.order_date)
ORDER BY
    year,
    month;


-- Revenue by calendar month

SELECT
    MONTHNAME(fc.order_date) AS month_name,
    SUM(fc.sales_amount) AS monthly_revenue
FROM fact_sales fc
WHERE fc.order_date IS NOT NULL
GROUP BY
    MONTHNAME(fc.order_date)
ORDER BY
    monthly_revenue DESC;


-- Average monthly revenue by calendar month

SELECT
    month,
    month_name,
    ROUND(AVG(monthly_revenue), 2) AS avg_monthly_revenue
FROM (
    SELECT
        YEAR(fc.order_date) AS year,
        MONTH(fc.order_date) AS month,
        MONTHNAME(fc.order_date) AS month_name,
        SUM(fc.sales_amount) AS monthly_revenue
    FROM fact_sales fc
    WHERE fc.order_date IS NOT NULL
    GROUP BY
        YEAR(fc.order_date),
        MONTH(fc.order_date),
        MONTHNAME(fc.order_date)
) t
GROUP BY
    month,
    month_name
ORDER BY
    month;
