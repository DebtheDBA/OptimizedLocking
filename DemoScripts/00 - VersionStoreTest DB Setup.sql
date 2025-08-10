USE master
GO


IF EXISTS (SELECT * FROM sys.databases WHERE name = 'VersionStoreTest')
DROP DATABASE VersionStoreTest
GO

CREATE DATABASE VersionStoreTest
GO

USE VersionStoreTest
GO


/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO



/*****************************************/
DROP TABLE IF EXISTS dbo.Customer
/* create table and populate from AdventureWorks */
CREATE TABLE dbo.Customer
(
    CustomerID int NOT NULL IDENTITY(1, 1)
        CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED,
    FirstName varchar (100) NULL,
    LastName varchar (100) NULL,
    Address varchar (50) NULL,
    City varchar (50) NULL,
    State char (3) NULL,
    ZipCode varchar (15) NULL,
    Email varchar (100) NULL,
    PhoneNumber char (10) NULL,
    FirstVisit date NULL,
    RepeatCustomer bit NULL
) 
GO


INSERT INTO dbo.Customer
(
    FirstName,
    LastName,
    Address,
    City,
    State,
    ZipCode,
    RepeatCustomer
)
SELECT p.FirstName, 
    p.LastName,
    a.AddressLine1,
    a.City,
    sp.StateProvinceCode,
    a.PostalCode,
    1 AS RepeatCustomer
FROM AdventureWorks.Person.Person AS p
    JOIN AdventureWorks.Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
    JOIN AdventureWorks.Person.Address AS a ON a.AddressID = bea.AddressID
    JOIN AdventureWorks.Person.StateProvince AS sp ON sp.StateProvinceID = a.StateProvinceID
--WHERE /*p.FirstName = 'Sebastian'
--AND */sp.CountryRegionCode = 'US'
GO
