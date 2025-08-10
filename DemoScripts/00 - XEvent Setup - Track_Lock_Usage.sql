/* clean up existing session if it exists */
IF EXISTS (
    SELECT * FROM sys.server_event_sessions
    WHERE name = 'Track_Lock_Usage'
    )
DROP EVENT SESSION [Track_Lock_Usage] ON SERVER
GO

DECLARE @deletefiles VARCHAR(100) = 'del "C:\XE_Logs\*.xel"'
EXEC sys.xp_cmdshell @deletefiles
GO


/* Create session showing lock escalation and release */
CREATE EVENT SESSION [Track_Lock_Usage]
ON SERVER
ADD EVENT sqlserver.lock_acquired
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.session_id,
        sqlserver.database_id,
        sqlserver.plan_handle
    )
    WHERE (
        [sqlserver].[database_name] = N'AutoDealershipDemo' AND 
        resource_type <> N'DATABASE'
    )
),
ADD EVENT sqlserver.lock_released
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.session_id,
        sqlserver.database_id,
        sqlserver.plan_handle
    )
    WHERE (
        [sqlserver].[database_name] = N'AutoDealershipDemo' AND 
        resource_type <> N'DATABASE'
    )
),
ADD EVENT sqlserver.lock_escalation
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.session_id,
        sqlserver.database_id,
        sqlserver.plan_handle
    )
    WHERE (
        [sqlserver].[database_name] = N'AutoDealershipDemo' AND 
        resource_type <> N'DATABASE'
    )
),
ADD EVENT sqlserver.sql_batch_completed
(ACTION
    (
        sqlserver.client_app_name,
        sqlserver.database_id,
        sqlserver.query_hash,
        sqlserver.request_id,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.transaction_id,
        sqlserver.transaction_sequence
    )
    WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo' )
),
ADD EVENT sqlserver.sql_batch_starting
(ACTION
    (
        sqlserver.request_id,
        sqlserver.sql_text,
        sqlserver.transaction_id,
        sqlserver.transaction_sequence
    )
    WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo' )
),
ADD EVENT sqlserver.sql_statement_completed
(ACTION
    (
        sqlserver.client_app_name,
        sqlserver.database_id,
        sqlserver.query_hash,
        sqlserver.query_plan_hash,
        sqlserver.request_id,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.transaction_id,
        sqlserver.transaction_sequence
    )
    WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo' )
),
ADD EVENT sqlserver.sql_statement_starting
(ACTION
    (
        sqlserver.request_id,
        sqlserver.sql_text,
        sqlserver.transaction_id,
        sqlserver.transaction_sequence
    )
    WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo' )
)
ADD TARGET package0.event_file
(
    SET filename = N'C:\XE_Logs\LockTracking.xel',
        max_file_size = 50,
        max_rollover_files = 5
)
WITH (
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 5 SECONDS
);
GO

