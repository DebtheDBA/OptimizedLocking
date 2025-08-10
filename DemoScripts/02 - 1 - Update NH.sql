USE AutoDealershipDemo
GO


BEGIN TRANSACTION updateNH


UPDATE c
SET c.FirstVisit = GETDATE()
FROM dbo.Customer AS c
WHERE c.State = 'NH'
GO

/* check locks first */

ROLLBACK TRANSACTION updateNH
