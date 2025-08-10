/* Script used to create the tests.

Run this 3 times: 
1. no RCSI & ADR
2. with just optimized locking and no RCSI
3. with both optized locking and RCSI

In my testing, I saved the file as a different name after each test.
*/

USE AutoDealershipDemo
GO

/* Confirm database settings */
SELECT snapshot_isolation_state_desc,
    is_read_committed_snapshot_on, 
    is_accelerated_database_recovery_on, 
    is_optimized_locking_on
FROM sys.databases WHERE database_id = DB_ID() 
GO


/* delete any active xevent files */
DECLARE @deletefiles VARCHAR(100) = 'del "C:\XE_Logs\*.xel"'
EXEC sys.xp_cmdshell @deletefiles
GO

/* Run these individually to make sure the file captures everything */
/* start the xevents */
ALTER EVENT SESSION [Track_Lock_Usage] ON SERVER STATE = START;
GO

/* run these statement together*/
BEGIN TRANSACTION LockRelease

    -- example
    UPDATE c
    SET c.FirstVisit = GETDATE()
    FROM dbo.Customer AS c
    WHERE FirstName = 'Sebastian'
    AND State = 'CA'

COMMIT TRANSACTION LockRelease
GO

/* run these statement together*/
BEGIN TRANSACTION LockRelease2

    -- example
    UPDATE c
    SET c.FirstVisit = c.FirstVisit
    FROM dbo.Customer AS c
    WHERE State = 'NH'

COMMIT TRANSACTION LockRelease2
GO

/* stop the xevents */
ALTER EVENT SESSION [Track_Lock_Usage] ON SERVER STATE = STOP;
GO