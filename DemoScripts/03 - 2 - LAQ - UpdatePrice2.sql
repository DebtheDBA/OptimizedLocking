USE AutoDealershipDemo
GO

BEGIN TRANSACTION UpdatePrice2

UPDATE sh
SET sh.TransactionDate = '2025-07-25 9:00PM',
	SellPrice = CONVERT(INT, SellPrice - 1000) -- no decimal value results
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128
GO

-- Blocking is expected.
-- Now go back and commit the first transaction
COMMIT TRANSACTION UpdatePrice2
GO


/* what are the results? */
SELECT sh.SalesHistoryID, 
	sh.TransactionDate AS NewTransactionDate,
	CONVERT(DATETIME, '2025-07-25 8:00PM') AS NewDateFromUpdate1,
	CONVERT(DATETIME, '2025-07-25 9:00PM') AS NewDateFromUpdate2,
	27141.682 AS OrigPrice,
	SellPrice
FROM dbo.SalesHistory AS sh
WHERE sh.SalesHistoryID = 138128
