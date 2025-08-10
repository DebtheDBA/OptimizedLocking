USE AutoDealershipDemo
GO

BEGIN TRAN UpdateCust2

UPDATE c
SET c.Email = firstname + '@' + lastname + '.fake.org'
FROM dbo.Customer AS c
WHERE FirstName = 'Sebastian'
AND State = 'CA'
GO

-- commit the other transaction

COMMIT TRAN UpdateCust2
GO

SELECT *
FROM dbo.Customer AS c
WHERE FirstName = 'Sebastian'
AND State = 'CA'
GO




