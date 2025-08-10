USE AutoDealershipDemo
GO


-- Writes blocking reads
SELECT * 
FROM dbo.Customer AS c
WHERE c.State = 'MA'
GO



-- Now for the update, try the next one:

BEGIN TRANSACTION updateMA

UPDATE c
SET c.FirstVisit = GETDATE()
FROM dbo.Customer AS c
WHERE c.State = 'MA'
GO

/* check locks first */

ROLLBACK TRANSACTION updateMA
GO


