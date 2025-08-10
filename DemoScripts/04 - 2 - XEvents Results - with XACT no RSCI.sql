/*
Read the file with the results for optimized locking with no RCSI

Notice for the smaller transaction that there are still locks on keys being taken.
But they are being released BEFORE the transaction is committed.

For the larger update, we see the XACT lock being taken early but as individual
locks are enough for lock escalation, we don't see them being released the same way.
*/

DECLARE @eventFileTarget NVARCHAR(400) = 'C:\XE_Logs\LockTracking_with_XACT_no_RCSI.xel.bckp' 

SELECT 
	n.value( '(@timestamp)[1]', 'datetime2' ) AS [utc_timestamp], 
	n.value( '(action[@name="database_id"]/value)[1]', 'bigint' ) AS database_id,
	n.value( '(action[@name="sql_text"]/value)[1]', 'nvarchar(max)' ) AS sql_text,
	n.value( '(data[@name="statement"]/value)[1]', 'nvarchar(max)' ) AS sql_statement,
    n.value('(data[@name="transaction_id"]/value)[1]', 'varchar(20)') AS transaction_id,
	DB_NAME(n.value( '(action[@name="database_id"]/value)[1]', 'bigint' )) AS database_name,
	OBJECT_NAME(n.value( '(data[@name="object_id"]/value)[1]', 'nvarchar(max)' )) AS objectname,
    n.value( '(@name)[1]', 'varchar(50)' ) AS event_name, 
	--n.value('(data[@name="resource_type"]/value)[1]', 'varchar(50)') AS resource_type,
    rt.map_value AS lock_type,
    --n.value('(data[@name="mode"]/value)[1]', 'varchar(20)') AS lock_mode,
    lm.map_value AS lock_mode_type
FROM
        (
            SELECT CAST(event_data AS XML) AS event_data
            FROM sys.fn_xe_file_target_read_file( @EventFileTarget, NULL, NULL, NULL )
        ) AS ed
    CROSS APPLY
        ed.event_data.nodes( 'event' ) AS q(n)
    LEFT JOIN (
        SELECT name, map_key, map_value
        FROM sys.dm_xe_map_values
        WHERE name = 'lock_resource_type'
        ) AS rt ON n.value('(data[@name="resource_type"]/value)[1]', 'varchar(50)') = rt.map_key
    LEFT JOIN (
        SELECT name, map_key, map_value
        FROM sys.dm_xe_map_values
        WHERE name = 'lock_mode'
        ) AS lm ON n.value('(data[@name="mode"]/value)[1]', 'varchar(20)') = lm.map_key
WHERE 
    (
    n.value( '(action[@name="sql_text"]/value)[1]', 'nvarchar(max)' )  LIKE '%BEGIN TRANSACTION LockRelease%'
    )
AND (
    lm.map_value IS NULL OR 
    lm.map_value IN ('X', 'IX')
    )
ORDER BY utc_timestamp

