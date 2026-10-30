/*
=================================================================
Create Database and Schemas
=================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Datawarehouse_P' database

IF EXISTS ( SELECT 1 FROM sys.databases where name = 'Datawarehouse_P')
BEGIN 
  ALTER DATABASE Datawarehouse_P SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE Datawarehouse_P;
END;
GO

--Create new database 'Datawarehouse_P'

CREATE DATABASE Datawarehouse_P;
GO

USE Datawarehouse_P;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
