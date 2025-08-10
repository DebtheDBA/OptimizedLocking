USE AutoDealershipDemo
GO

/* what happens if we run the same update at the same time */

SELECT sh.SalesHistoryID, 
	sh.TransactionDate,
	SellPrice
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128

/* these values should be:
SalesHistoryID  = 138128	
TransactionDate = 2022-10-31 21:12:22.000	
SellPrice		= 27141.682
			
-- query to reset this record if I forgot to do this earlier:
UPDATE sh
SET sh.TransactionDate = '2022-10-31 21:12:22.000',
	SellPrice = 27141.682
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128

*/

BEGIN TRANSACTION UpdatePrice1

UPDATE sh
SET sh.TransactionDate = '2025-07-25 8:00PM',
	SellPrice = SellPrice - 1000	-- NewPrice = 26141.682
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128
GO

-- run the second transaction

COMMIT TRANSACTION UpdatePrice1
GO
