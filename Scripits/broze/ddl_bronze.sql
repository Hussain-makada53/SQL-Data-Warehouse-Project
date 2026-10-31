/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info', 'U') is NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR (50),
	cst_firstname VARCHAR (50),
	cst_lastname VARCHAR (50),
	cst_maritial_status VARCHAR (50),
	cst_gender VARCHAR (50),
	cst_create_date DATE
);
GO

IF OBJECT_ID ('bronze.crm_prd_info', 'U') is NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key VARCHAR (50),
	prd_nm VARCHAR (50),
	prd_cost INT,
	prd_line VARCHAR (50),
	prd_start_date DATE,
	prd_end_date DATE
); 
GO

IF OBJECT_ID ('bronze.crm_sales_details', 'U') is NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num VARCHAR (50),
	sls_prd_key VARCHAR (50),
	sls_cust_id INT,
	sls_order_date INT,
	sls_ship_date DATE,
	sls_due_date DATE,
	sls_sales INT,
	sls_qunatity INT,
	sls_price INT
);
GO

IF OBJECT_ID ('bronze.erp_CUST_AZ12', 'U') is NOT NULL
	DROP TABLE bronze.erp_CUST_AZ12;
GO

CREATE TABLE bronze.erp_CUST_AZ12 (
	CID VARCHAR (50),
	BDATE DATE,
	GEN VARCHAR (25)
);
GO

IF OBJECT_ID ('bronze.erp_LOC_A101', 'U') is NOT NULL
	DROP TABLE bronze.erp_LOC_A101;
GO

CREATE TABLE bronze.erp_LOC_A101 (
	CID VARCHAR (50),
	COUNTRY VARCHAR (50)
);
GO

IF OBJECT_ID ('bronze.erp_PX_CAT_G1V2', 'U') is NOT NULL
	DROP TABLE bronze.erp_PX_CAT_G1V2;
GO

CREATE TABLE bronze.erp_PX_CAT_G1V2 (
	ID VARCHAR (50),
	CAT VARCHAR (50),
	SUBCAT VARCHAR (50),
	MAINTENANCE VARCHAR (50)
);
GO
