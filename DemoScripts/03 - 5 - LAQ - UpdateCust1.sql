USE AutoDealershipDemo
GO

/* what happens with LAQ if the record will be updated 
to match the next transaction? */

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
