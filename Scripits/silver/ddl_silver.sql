/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' schema, dropping existing tables
    if they already exist.
  Run this script to re-define the DDL structure of 'Silver' Tables
===============================================================================
*/
IF OBJECT_ID ('silver.crm_cust_info', 'U') is NOT NULL
	DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR (50),
	cst_firstname VARCHAR (50),
	cst_lastname VARCHAR (50),
	cst_maritial_status VARCHAR (50),
	cst_gender VARCHAR (50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('silver.crm_prd_info', 'U') is NOT NULL
	DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id VARCHAR (50),
	prd_key VARCHAR (50),
	prd_nm VARCHAR (50),
	prd_cost INT,
	prd_line VARCHAR (50),
	prd_start_date DATE,
	prd_end_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO

IF OBJECT_ID ('silver.crm_sales_details', 'U') is NOT NULL
	DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
	sls_ord_num VARCHAR (50),
	sls_prd_key VARCHAR (50),
	sls_cust_id INT,
	sls_order_date DATE,
	sls_ship_date DATE,
	sls_due_date DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('silver.erp_CUST_AZ12', 'U') is NOT NULL
	DROP TABLE silver.erp_CUST_AZ12;
GO

CREATE TABLE silver.erp_CUST_AZ12 (
	CID VARCHAR (50),
	BDATE DATE,
	GEN VARCHAR (25),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('silver.erp_LOC_A101', 'U') is NOT NULL
	DROP TABLE silver.erp_LOC_A101;
GO

CREATE TABLE silver.erp_LOC_A101 (
	CID VARCHAR (50),
	COUNTRY VARCHAR (50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('silver.erp_PX_CAT_G1V2', 'U') is NOT NULL
	DROP TABLE silver.erp_PX_CAT_G1V2;
GO

CREATE TABLE silver.erp_PX_CAT_G1V2 (
	ID VARCHAR (50),
	CAT VARCHAR (50),
	SUBCAT VARCHAR (50),
	MAINTENANCE VARCHAR (50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
