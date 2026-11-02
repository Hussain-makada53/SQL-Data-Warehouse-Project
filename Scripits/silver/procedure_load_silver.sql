CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time = GETDATE();
	BEGIN TRY
		PRINT '================================================';
		PRINT 'Loading Silver Layer';
		PRINT '================================================';
	
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.crm_cust_info >';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '< Inserting Table: silver.crm_cust_info >';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_maritial_status,
			cst_gender,
			cst_create_date
		)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE 
			UPPER(TRIM(cst_martial_status))
			WHEN 'M' THEN 'Married'
			WHEN 'S' THEN 'Single'
			ELSE 'n/a'
		END AS cst_maritial_status	,
		CASE
			UPPER(TRIM(cst_gender))
			WHEN 'M' THEN 'Male'
			WHEN 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gender,
		cst_create_date
		FROM (SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as Flag
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL)t
		WHERE Flag = 1;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'

		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.crm_prd_info >';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '< Inserting Table: silver.crm_prd_info >';

		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_date,
			prd_end_date
		)
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE
			UPPER(TRIM(prd_line))
			WHEN 'R' THEN 'Right Line'
			WHEN 'S' THEN 'Store Line'
			WHEN 'M' THEN 'Main Line'
			WHEN 'T' THEN 'Transit Line'
			ELSE 'n/a'
		END AS prd_line,
		prd_start_date,
		CAST(
			DATEADD(DAY, -1, LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date))
			AS DATE
		) AS prd_end_date
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'

		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.crm_sales_details >';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '< Inserting Table: silver.crm_sales_details >';

		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_date,
			sls_ship_date,
			sls_due_date,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_date = 0	OR LEN(sls_order_date) !=8 THEN NULL
			ELSE CAST(CAST(sls_order_date AS VARCHAR) AS DATE)
		END AS sls_order_date,
		sls_ship_date,
		sls_due_date,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <=0
			THEN sls_sales/ nullif(sls_quantity,0)
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'

		PRINT '------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.erp_CUST_AZ12 >';
		TRUNCATE TABLE silver.erp_CUST_AZ12;
		PRINT '< Inserting Table: silver.erp_CUST_AZ12 >';

		INSERT INTO silver.erp_CUST_AZ12 (
		CID,
		BDATE,
		GEN
		)
		SELECT
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
			ELSE CID
		END AS CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE
		END AS BDATE,
		CASE WHEN GEN IN ('M', 'Male') THEN 'Male'
			WHEN GEN IN ('F', 'Female') THEN 'Female'
			ELSE 'n/a'
		END AS GEN
		FROM bronze.erp_CUST_AZ12;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'
		
		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.erp_LOC_A101 >';
		TRUNCATE TABLE silver.erp_LOC_A101;
		PRINT '< Inserting Table: silver.erp_LOC_A101 >';

		INSERT INTO silver.erp_LOC_A101 (
		CID,
		COUNTRY
		)
		SELECT
		REPLACE(CID, '-', '') AS CID,
		CASE WHEN COUNTRY IN ('US','USA','United States') THEN 'United States'
			WHEN COUNTRY IN ('DE', 'Germany') THEN 'Germany'
			WHEN COUNTRY = 'Australia' THEN 'Australia'
			WHEN COUNTRY = 'Canada' THEN 'Canada'
			WHEN COUNTRY = 'France' THEN 'France'
			WHEN COUNTRY = 'United Kingdom' THEN 'United Kingdom'
			ELSE 'n/a'
		END AS COUNTRY
		FROM bronze.erp_LOC_A101;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'
		
		SET @start_time = GETDATE();
		PRINT '< Truncating Table: silver.erp_PX_CAT_G1V2 >';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
		PRINT '< Inserting Table: silver.erp_PX_CAT_G1V2 >';

		INSERT INTO silver.erp_PX_CAT_G1V2 (
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		)
		SELECT 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		FROM bronze.erp_PX_CAT_G1V2;
		SET @end_time = GETDATE();
		PRINT '-- Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '*************************'
		
		
		SET @batch_end_time = GETDATE();
		PRINT '++++++++++++++++++++++++++++++++++++++++++'
		PRINT ' Loading Silver Layer Completed'
		PRINT '-- Load Duration Of Silver Layer ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
		PRINT '++++++++++++++++++++++++++++++++++++++++++'
	END TRY
	BEGIN CATCH
	PRINT '-----------------------------------------------------------';
	PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Message' + CAST(ERROR_NUMBER() AS VARCHAR);
	PRINT 'Error Message' + CAST(ERROR_LINE() AS VARCHAR);
	PRINT 'Error Message' + CAST(ERROR_STATE() AS VARCHAR);
	PRINT '-----------------------------------------------------------';
	END CATCH

END
