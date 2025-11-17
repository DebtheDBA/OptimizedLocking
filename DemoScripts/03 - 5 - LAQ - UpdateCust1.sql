USE AutoDealershipDemo
GO

/* what happens with LAQ if the record will be updated 
to match the next transaction? */


/* record sets before we update them */
SELECT * 
FROM Customer AS c 
WHERE c.LastName = 'Melkin-Yun'
GO

SELECT *
FROM dbo.Customer AS c
WHERE c.FirstName = 'Sebastian'
AND c.State = 'CA'
GO



/* update the state  */
BEGIN TRAN UpdateCust1

UPDATE c
SET State = 'CA'
FROM Customer AS C 
WHERE LastName = 'Melkin-Yun'
GO

-- start next transaction
COMMIT TRAN UpdateCust1
GO
