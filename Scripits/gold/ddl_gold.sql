/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cc.COUNTRY AS country,
	ci.cst_maritial_status AS maritial_status,
	CASE WHEN ci.cst_gender != 'n/a' THEN ci.cst_gender 
		 ELSE	COALESCE(cs.GEN, 'n/a')
	END AS gender,
	cs.BDATE AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_CUST_AZ12 cs
ON ci.cst_key=cs.CID
LEFT JOIN silver.erp_LOC_A101 cc
ON ci.cst_key=cc.CID 

GO
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER( ORDER BY pr.prd_start_date, pr.prd_key) AS product_key,
	pr.prd_id AS product_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	pd.CAT AS category,
	pd.SUBCAT AS sub_category,
	pd.MAINTENANCE AS maintenance,
	pr.prd_cost AS product_cost,
	pr.prd_line AS produt_line,
	pr.prd_start_date AS product_start_date
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_PX_CAT_G1V2 pd
ON pr.cat_id = pd.ID 
WHERE pr.prd_end_date IS NULL ----- TO FIND THE ACTIVE PRD DATA

GO
    
-- =============================================================================
-- Create Dimension: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num,
	dp.product_key,
	cd.customer_key,
	sd.sls_order_date,
	sd.sls_ship_date,
	sd.sls_due_date,
	sd.sls_quantity,
	sd.sls_price,
	sd.sls_sales
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers cd
ON sd.sls_cust_id = cd.customer_id

