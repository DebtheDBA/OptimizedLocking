USE VersionStoreTest
GO

/* Let's look at the different version stores */


DBCC USEROPTIONS

/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO

/* tempdb's version store with info about this db */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()


/* this database's persistent version store */
SELECT * 
FROM sys.dm_tran_persistent_version_store --row_version 
GO

/* persistent version store stats */
SELECT * 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = DB_ID()

/*
Create data for the tempdb version store
*/

ALTER DATABASE VersionStoreTest
SET READ_COMMITTED_SNAPSHOT ON
WITH ROLLBACK IMMEDIATE;

DBCC USEROPTIONS

/*
-- notice this is not turned on 
-- doesn't have to be; probably doesn't hurt
ALTER DATABASE VersionStoreTest
SET ALLOW_SNAPSHOT_ISOLATION ON
GO
*/

/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO


/* Update Customer */

BEGIN TRAN UpdateCustVS1

UPDATE c
SET c.Email = firstname + '@' + lastname + '.fake.org'
FROM dbo.Customer AS c
WHERE State = 'CA'
GO


/* check both version stores */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()

-- storage used in tempdb for this database
SELECT *
FROM sys.dm_tran_version_store_space_usage
WHERE database_id = DB_ID()


SELECT * 
FROM sys.dm_tran_persistent_version_store 
GO

-- get the latest transactions and look at the stats for PVS
SELECT * FROM sys.dm_tran_active_transactions

SELECT database_id,
       pvs_filegroup_id,
       persistent_version_store_size_kb,
       online_index_version_store_size_kb,
       current_aborted_transaction_count,
       oldest_active_transaction_id, -- transaction sequence id in tempdb VS
       oldest_active_transaction_global_id, -- transaction id in dm_active_tran
       oldest_aborted_transaction_id,
       min_transaction_timestamp,
       online_index_min_transaction_timestamp,
       --secondary_low_water_mark,
       GETDATE() AS Debs_CurrentDatetime,
       offrow_version_cleaner_start_time,
       offrow_version_cleaner_end_time,
       aborted_version_cleaner_start_time,
       aborted_version_cleaner_end_time,
       --pvs_off_row_page_skipped_low_water_mark,
       pvs_off_row_page_skipped_transaction_not_cleaned,
       pvs_off_row_page_skipped_oldest_active_xdesid,
       pvs_off_row_page_skipped_min_useful_xts,
       pvs_off_row_page_skipped_oldest_snapshot,
       pvs_off_row_page_skipped_oldest_aborted_xdesid 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = DB_ID()


ROLLBACK TRAN UpdateCustVS1


/* check both version stores */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()


SELECT * 
FROM sys.dm_tran_persistent_version_store 
GO

/* This may take a bit to clear due to ASYNC cleaners */

/* Enable Accelerated Database Recovery */

/* Optional: disable RSCI 

ALTER DATABASE VersionStoreTest
SET READ_COMMITTED_SNAPSHOT OFF
WITH ROLLBACK IMMEDIATE;
*/


ALTER DATABASE VersionStoreTest
SET ACCELERATED_DATABASE_RECOVERY = ON
WITH ROLLBACK IMMEDIATE;
GO


/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO

/* Rerun the same update test */
BEGIN TRAN UpdateCustVS2

UPDATE c
SET c.Email = firstname + '@' + lastname + '.fake.org'
FROM dbo.Customer AS c
WHERE State = 'CA'
GO


/* check both version stores */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()


SELECT * 
FROM sys.dm_tran_persistent_version_store 
GO

-- get the latest transactions and look at the stats for PVS
SELECT * FROM sys.dm_tran_active_transactions

SELECT database_id,
       pvs_filegroup_id,
       persistent_version_store_size_kb,
       online_index_version_store_size_kb,
       current_aborted_transaction_count,
       oldest_active_transaction_id,
       oldest_active_transaction_global_id,
       oldest_aborted_transaction_id,
       min_transaction_timestamp,
       online_index_min_transaction_timestamp,
       secondary_low_water_mark,
       GETDATE() AS currentdatetime,
       offrow_version_cleaner_start_time,
       offrow_version_cleaner_end_time,
       aborted_version_cleaner_start_time,
       aborted_version_cleaner_end_time,
       pvs_off_row_page_skipped_low_water_mark,
       pvs_off_row_page_skipped_transaction_not_cleaned,
       pvs_off_row_page_skipped_oldest_active_xdesid,
       pvs_off_row_page_skipped_min_useful_xts,
       pvs_off_row_page_skipped_oldest_snapshot,
       pvs_off_row_page_skipped_oldest_aborted_xdesid 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = DB_ID()

/* Let's check out the physical stats of the database */
SELECT database_id,
       object_id,
       index_id,
       partition_number,
       index_type_desc,
       alloc_unit_type_desc,
       version_record_count,
       inrow_version_record_count,
       inrow_diff_version_record_count,
       total_inrow_version_payload_size_in_bytes,
       offrow_regular_version_record_count,
       offrow_long_term_version_record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Customer'), NULL, NULL, 'DETAILED')

/* try rerunning that update... */

/* rollback */
ROLLBACK TRAN UpdateCustVS2
GO

/* check both version stores */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()


SELECT * 
FROM sys.dm_tran_persistent_version_store 
GO

SELECT database_id,
       pvs_filegroup_id,
       persistent_version_store_size_kb,
       online_index_version_store_size_kb,
       current_aborted_transaction_count,
       oldest_active_transaction_id,
       oldest_active_transaction_global_id,
       oldest_aborted_transaction_id,
       min_transaction_timestamp,
       online_index_min_transaction_timestamp,
       secondary_low_water_mark,
       GETDATE() AS currentdatetime,
       offrow_version_cleaner_start_time,
       offrow_version_cleaner_end_time,
       aborted_version_cleaner_start_time,
       aborted_version_cleaner_end_time,
       pvs_off_row_page_skipped_low_water_mark,
       pvs_off_row_page_skipped_transaction_not_cleaned,
       pvs_off_row_page_skipped_oldest_active_xdesid,
       pvs_off_row_page_skipped_min_useful_xts,
       pvs_off_row_page_skipped_oldest_snapshot,
       pvs_off_row_page_skipped_oldest_aborted_xdesid 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = DB_ID()

GO

/*******************************************/
/*******************************************/
/*******************************************/
/*******************************************/
/*******************************************/
/*******************************************/
/* Optional Demo: Enable Optimized Locking

This should work the same as above since it's using ADR

*/

ALTER DATABASE VersionStoreTest
SET OPTIMIZED_LOCKING = ON
WITH ROLLBACK IMMEDIATE;
GO


/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO


/* Rerun the same update test */
BEGIN TRAN UpdateCustVS3

UPDATE c
SET c.Email = firstname + '@' + lastname + '.fake.org'
FROM dbo.Customer AS c
WHERE State = 'CA'
GO


/* check both version stores */
SELECT * 
FROM tempdb.sys.dm_tran_version_store
WHERE database_id = DB_ID()


SELECT * 
FROM sys.dm_tran_persistent_version_store 
GO



SELECT database_id,
       pvs_filegroup_id,
       persistent_version_store_size_kb,
       online_index_version_store_size_kb,
       current_aborted_transaction_count,
       oldest_active_transaction_id,
       oldest_active_transaction_global_id,
       oldest_aborted_transaction_id,
       min_transaction_timestamp,
       online_index_min_transaction_timestamp,
       secondary_low_water_mark,
       GETDATE() AS currentdatetime,
       offrow_version_cleaner_start_time,
       offrow_version_cleaner_end_time,
       aborted_version_cleaner_start_time,
       aborted_version_cleaner_end_time,
       pvs_off_row_page_skipped_low_water_mark,
       pvs_off_row_page_skipped_transaction_not_cleaned,
       pvs_off_row_page_skipped_oldest_active_xdesid,
       pvs_off_row_page_skipped_min_useful_xts,
       pvs_off_row_page_skipped_oldest_snapshot,
       pvs_off_row_page_skipped_oldest_aborted_xdesid 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = DB_ID()

/* Let's check out the physical stats of the database */
SELECT database_id,
       object_id,
       index_id,
       partition_number,
       index_type_desc,
       alloc_unit_type_desc,
       version_record_count,
       inrow_version_record_count,
       inrow_diff_version_record_count,
       total_inrow_version_payload_size_in_bytes,
       offrow_regular_version_record_count,
       offrow_long_term_version_record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Customer'), NULL, NULL, 'DETAILED')

/* push the records to the PVS */

/* rollback */
ROLLBACK TRAN UpdateCustVS3
GO
