USE master
GO

/* now turn on optimized locking to see the change */
ALTER DATABASE AutoDealershipDemo
SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK IMMEDIATE;
GO


















-- Yes, I messed up the order on purpose
ALTER DATABASE AutoDealershipDemo 
SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK IMMEDIATE;
GO


/* Rerun Lock Escalation demos & Update 1 Demo */
