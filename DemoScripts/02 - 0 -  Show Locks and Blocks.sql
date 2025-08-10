USE AutoDealershipDemo
GO

/* check the isolation states */
SELECT snapshot_isolation_state_desc AS Is_Snapshot_On, 
    is_read_committed_snapshot_on AS Is_RCSI_On, 
    is_accelerated_database_recovery_on AS Is_ADR_On, 
    is_optimized_locking_on AS Is_OptimizedLocking_On
FROM sys.databases 
WHERE database_id = DB_ID() 
GO



/* check for open transactions */
SELECT * 
FROM sys.dm_tran_active_transactions
    
/* check locks */
SELECT DB_NAME(l.resource_database_id) AS ResourceDatabaseName,
       OBJECT_NAME(p.object_id) AS KeyLockTableName,
       l.resource_type,
       --l.resource_subtype,
       l.request_mode,
       l.request_type,
       l.request_status,
       COUNT(*)
--, *
FROM sys.dm_tran_locks AS l
    LEFT JOIN sys.partitions AS p
        ON l.resource_associated_entity_id = p.hobt_id
WHERE l.resource_type <> 'DATABASE'
GROUP BY DB_NAME(l.resource_database_id),
         l.resource_type,
         --l.resource_subtype,
         l.request_mode,
         l.request_type,
         l.request_status,
       OBJECT_NAME(p.object_id);



       
/* look at locks */
EXEC DBA..sp_WhoIsActive @get_locks = 1;


--/* check the tempdb version store */
--SELECT * FROM tempdb.sys.dm_tran_version_store
--WHERE database_id = DB_ID()

--/* check the persistent version store */
--SELECT * 
--FROM sys.dm_tran_persistent_version_store 


/* check for blocks */
EXEC DBA..sp_WhoIsActive
    @find_block_leaders = 1,
    @sort_order = '[blocked_session_count] DESC'




