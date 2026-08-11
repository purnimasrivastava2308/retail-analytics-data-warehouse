-- ============================================================
-- Fact Sales Table Partitioning
-- Partitioned by Order Year
-- ============================================================

USE retailanalyticsdw_gold;

ALTER TABLE fact_sales
PARTITION BY RANGE (YEAR(order_date)) (

    PARTITION p_2010 VALUES LESS THAN (2011),
    PARTITION p_2011 VALUES LESS THAN (2012),
    PARTITION p_2012 VALUES LESS THAN (2013),
    PARTITION p_2013 VALUES LESS THAN (2014),
    PARTITION p_2014 VALUES LESS THAN (2015),
    PARTITION p_future VALUES LESS THAN MAXVALUE

);
