/* Optional Demo - what happens when the update is rolled back */

USE AutoDealershipDemo
GO

/* what happens if the first transaction is rolled back? */

-- reset to original values
UPDATE sh
SET sh.TransactionDate = '2022-10-31 21:12:22.000',
	SellPrice = 27141.682
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128


BEGIN TRANSACTION UpdatePrice3

UPDATE sh
SET sh.TransactionDate = '2025-07-25 8:00PM',
	SellPrice = SellPrice - 1000	
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128
GO

-- run the second transaction

ROLLBACK TRANSACTION UpdatePrice3
GO
