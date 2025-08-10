USE master
GO

/* Turn on Read Committed Snapshot Isolation */

ALTER DATABASE AutoDealershipDemo
SET READ_COMMITTED_SNAPSHOT ON
WITH ROLLBACK IMMEDIATE;




-- notice this is not turned on 
-- doesn't have to be; probably doesn't hurt
ALTER DATABASE AutoDealershipDemo
SET ALLOW_SNAPSHOT_ISOLATION ON
GO
