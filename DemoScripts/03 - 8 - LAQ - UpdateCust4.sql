USE AutoDealershipDemo
GO

BEGIN TRAN UpdateCust4

UPDATE c
SET c.Email = firstname + '@' + lastname + '.fake.org'
FROM dbo.Customer AS c
WHERE FirstName = 'Sebastian'
AND State = 'CA'
GO

-- look at blocks
-- commit the other transaction

COMMIT TRAN UpdateCust4
GO

SELECT *
FROM dbo.Customer AS c
WHERE FirstName = 'Sebastian'

GO


