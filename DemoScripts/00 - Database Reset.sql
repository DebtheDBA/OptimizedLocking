
USE [AutoDealershipDemo]
GO


-- make sure this index is there
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Customer_State' AND object_id = OBJECT_ID(N'dbo.Customer'))
CREATE INDEX idx_Customer_State ON dbo.Customer([State])
GO

-- reset saleshistory record
UPDATE sh
SET sh.TransactionDate = '2022-10-31 21:12:22.000',
	SellPrice = 27141.682
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128


-- remove test record
DELETE FROM dbo.Customer WHERE LastName LIKE 'Melkin%'

-- if no sebastians are in the customer table, add from adventureworks
IF NOT EXISTS (SELECT *
    FROM dbo.Customer AS c
    WHERE c.FirstName = 'Sebastian'
    )
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
FROM adventureWorks.Person.Person AS p
    JOIN AdventureWorks.Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
    JOIN AdventureWorks.Person.Address AS a ON a.AddressID = bea.AddressID
    JOIN AdventureWorks.Person.StateProvince AS sp ON sp.StateProvinceID = a.StateProvinceID
WHERE p.FirstName = 'Sebastian'
AND sp.CountryRegionCode = 'US'

UPDATE c 
SET c.Email = NULL
FROM dbo.Customer AS c
WHERE c.FirstName = 'Sebastian'
AND c.Email IS NOT NULL
GO

INSERT INTO dbo.Customer
(
    FirstName,
    LastName,
    Address,
    City,
    State,
    ZipCode,
    Email,
    PhoneNumber,
    FirstVisit,
    RepeatCustomer
)
VALUES
(   'Sebastian', -- FirstName - varchar(100)
    'Melkin-Yun', -- LastName - varchar(100)
    '1234 Chihuahua Lane', -- Address - varchar(50)
    'Anywhere', -- City - varchar(50)
    'MA', -- State - char(2)
    '00000', -- ZipCode - char(5)
    NULL, -- Email - varchar(100)
    NULL, -- PhoneNumber - char(10)
    GETDATE(), -- FirstVisit - date
    NULL  -- RepeatCustomer - bit
    )
GO

USE [master]
GO

ALTER DATABASE AutoDealershipDemo
SET READ_COMMITTED_SNAPSHOT OFF
WITH ROLLBACK IMMEDIATE;

ALTER DATABASE AutoDealershipDemo
SET OPTIMIZED_LOCKING = OFF
WITH ROLLBACK IMMEDIATE;


ALTER DATABASE AutoDealershipDemo 
SET ACCELERATED_DATABASE_RECOVERY = OFF
WITH ROLLBACK IMMEDIATE;


ALTER DATABASE AutoDealershipDemo
SET ALLOW_SNAPSHOT_ISOLATION OFF
GO

