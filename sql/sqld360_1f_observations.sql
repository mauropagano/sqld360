DEF section_id = '1f';
DEF section_name = 'Observations';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'System-wide observations';
DEF main_table = 'V$PARAMETER2';
BEGIN
  :sql_text := '
WITH cbo_parameters AS (SELECT /*+ MATERIALIZE */ name, value, isdefault FROM gv$sys_optimizer_env),
     fix_controls   AS (SELECT /*+ MATERIALIZE */ bugno, value, is_default FROM gv$system_fix_control),
     instances      AS (SELECT /*+ MATERIALIZE */ version FROM v$instance)
SELECT scope, message
  FROM (SELECT ''SYSTEM'' scope, ''There are ''||num_nondef_fixc||'' CBO-related parameters set to non-default value'' message
           FROM (SELECT COUNT(*) num_nondef_fixc
                   FROM cbo_parameters 
                  WHERE isdefault = ''NO'')
          WHERE num_nondef_fixc > 0
        UNION ALL
        SELECT ''PARAMETER'', ''Parameter ''||name||'' is set to non-default value of ''||value
          FROM cbo_parameters 
         WHERE isdefault = ''NO''
        UNION ALL
        SELECT ''SYSTEM'', ''There are ''||num_nondef_fixc||'' fix_controls set to non-default value''
          FROM (SELECT COUNT(*) num_nondef_fixc
                  FROM fix_controls 
                 WHERE is_default = 0)
         WHERE num_nondef_fixc > 0
        UNION ALL
        SELECT ''FIX_CONTROL'', ''Fix control ''||bugno||'' is set to non-default value of ''||value
          FROM fix_controls 
         WHERE is_default = 0
        UNION ALL
        SELECT ''OFE'', ''OPTIMIZER_FEATURES_ENABLE set to a value (''||cbo_parameters.value||'') different than RDBMS version (''||db_version.version||'')'' 
         FROM cbo_parameters, 
              (SELECT DISTINCT version 
                 FROM instances) db_version
        WHERE cbo_parameters.name = ''optimizer_features_enable''
          AND cbo_parameters.value <> db_version.version
        )
';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Cursors and Plans specific observations';
DEF main_table = 'V$SQL_PLAN';
BEGIN
  :sql_text := '
WITH vsql           AS (SELECT /*+ MATERIALIZE */ DISTINCT optimizer_env_hash_value FROM gv$sql WHERE sql_id = ''&&sqld360_sqlid.''),
     vsqlplan       AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, id, operation, object_owner, object_name, cost, cardinality, filter_predicates FROM gv$sql_plan WHERE sql_id = ''&&sqld360_sqlid.''),
     dbahistsql     AS (SELECT /*+ MATERIALIZE */ DISTINCT optimizer_env_hash_value FROM dba_hist_sqlstat WHERE sql_id = ''&&sqld360_sqlid.'' AND ''&&diagnostics_pack.'' = ''Y''),
     dbahistsqlplan AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, id, operation, object_owner, object_name, cost, cardinality, filter_predicates FROM dba_hist_sql_plan WHERE sql_id = ''&&sqld360_sqlid.'' AND ''&&diagnostics_pack.'' = ''Y''),
     indexes        AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, owner, index_name, degree FROM dba_indexes WHERE (table_owner, table_name) IN &&tables_list.),
     ashdata        AS (SELECT /*+ INLINE */ cost sql_plan_hash_value, 
                               operation sql_plan_operation, 
                               options sql_plan_options, 
                               object_node event, 
                               other_tag wait_class, 
                               id sql_plan_line_id,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'','',1,2)+1,INSTR(partition_start,'','',1,3)-INSTR(partition_start,'','',1,2)-1)) p1,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'','',1,4)+1,INSTR(partition_start,'','',1,5)-INSTR(partition_start,'','',1,4)-1)) p2,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'','',1,6)+1,INSTR(partition_start,'','',1,7)-INSTR(partition_start,'','',1,6)-1)) p3 
                          FROM plan_table 
                         WHERE statement_id 
                          LIKE ''SQLD360_ASH_DATA%'' 
                          AND remarks = ''&&sqld360_sqlid.'')
SELECT scope, message
  FROM (SELECT ''OPTIMIZER_ENV'' scope, ''There is(are) ''||COUNT(DISTINCT optimizer_env_hash_value)||'' distinct CBO environments between memory and history for this SQL'' message
         FROM (SELECT optimizer_env_hash_value 
                 FROM vsql
                UNION ALL
               SELECT optimizer_env_hash_value
                 FROM dbahistsql)
         UNION ALL
        SELECT ''INTERNAL_FUNCTION'', ''Filter predicate potentially include implicit data-type conversion (might be a red herring in case of long in-list)''
          FROM (SELECT 1
                  FROM vsqlplan
                 WHERE filter_predicates LIKE ''%INTERNAL FUNCTION%''
                   AND ROWNUM < 2
                 UNION ALL
                SELECT 1
                  FROM dbahistsqlplan
                 WHERE filter_predicates LIKE ''%INTERNAL FUNCTION%''
                   AND ROWNUM < 2)
         WHERE ROWNUM < 2
         UNION ALL
        SELECT ''COST_OF_0'', ''Plan Hash Value ''||plan_hash_value||'' includes operation with a cost of 0, VERY suspicious''
          FROM (SELECT plan_hash_value
                  FROM vsqlplan
                 WHERE cost = 0 
                   AND cardinality >= 1 -- always true, btw
                 UNION
                SELECT plan_hash_value
                  FROM dbahistsqlplan
                 WHERE cost = 0 
                   AND cardinality >= 1 -- always true, btw
                )
         UNION ALL
        SELECT DISTINCT ''INDEX_NOT_FOUND'', ''Plan Hash Value ''||plan_hash_value||'' refences an index that was not found anymore, maybe dropped?''
          FROM (SELECT plan_hash_value, object_owner, object_name
                  FROM vsqlplan
                 WHERE operation = ''INDEX''
                 UNION
                SELECT plan_hash_value, object_owner, object_name
                  FROM dbahistsqlplan
                 WHERE operation = ''INDEX''
                ) plans,
               indexes
         WHERE plans.object_owner = indexes.owner(+)
           AND plans.object_name = indexes.index_name(+)
           AND indexes.index_name IS NULL
         UNION ALL
        SELECT ''FULL_SCAN_DOING_SINGLE_READS'', ''From the ASH *sampled* data for physical reads, Plan Hash Value ''||sql_plan_hash_value||'' issued single block reads during full scan operations ''||TRUNC(num_single_block_reads/num_samples,3)*100||''% of the times'' 
          FROM (SELECT sql_plan_hash_value,
                       COUNT(*) num_samples, 
                       SUM(CASE WHEN event IN (''db file sequential read'', ''cell single block physical read'') THEN 1 ELSE 0 END) num_single_block_reads
                  FROM ashdata
                 WHERE sql_plan_operation IN (''TABLE ACCESS'',''INDEX'')
                   AND sql_plan_options LIKE ''FULL%''
                   AND wait_class = ''User I/O'' 
                 GROUP BY sql_plan_hash_value)
         WHERE TRUNC(num_single_block_reads/num_samples,3) >= 0.02 -- 2%
        )
';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Table-level observations';
DEF main_table = 'DBA_TABLES';
BEGIN
  :sql_text := '
WITH tables    AS (SELECT /*+ MATERIALIZE */ owner, table_name, num_rows, blocks, last_analyzed, degree
                     FROM dba_tables 
                    WHERE (owner, table_name) IN &&tables_list.),
     partitions AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, partition_name, num_rows, blocks, last_analyzed
                      FROM dba_tab_partitions 
                     WHERE (table_owner, table_name) IN &&tables_list.),
     table_and_part_stats AS (SELECT /*+ MATERIALIZE */ owner, table_name, partition_name, stale_stats, stattype_locked
                                FROM dba_tab_statistics
                               WHERE (owner, table_name) IN &&tables_list.
                                 AND subpartition_name IS NULL),
     indexes    AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, index_name, degree
                      FROM dba_indexes
                     WHERE (table_owner, table_name) IN &&tables_list.)
SELECT scope, owner, table_name, message
  FROM (SELECT ''TABLE_STATS'' scope, owner, table_name,  ''Table ''||table_name||'' has statistics more than a month old (''||TRUNC(SYSDATE-last_analyzed)||'' days old)'' message
          FROM tables
         WHERE last_analyzed < ADD_MONTHS(TRUNC(SYSDATE),-1)
         UNION ALL
        SELECT ''TABLE_STALE_STATS'', owner, table_name,  ''Table ''||table_name||'' has stale stats''
          FROM table_and_part_stats
         WHERE stale_stats = ''YES''
           AND partition_name IS NULL
         UNION ALL
        SELECT ''TABLE_LOCKED_STATS'', owner, table_name,  ''Table ''||table_name||'' has locked stats''
          FROM table_and_part_stats
         WHERE stattype_locked IN (''ALL'',''DATA'')
           AND partition_name IS NULL
         UNION ALL
        SELECT ''TABLE_MISSING_STATS'', owner, table_name,  ''Table ''||table_name||'' has no stats''
          FROM tables
         WHERE num_rows IS NULL
         UNION ALL
        SELECT ''PARTITION_STATS'', table_owner, table_name,  ''Table ''||table_name||'' has ''||num_old_parts||''partitions with statistics more than a month old''
          FROM (SELECT COUNT(*) num_old_parts, table_owner, table_name
                  FROM partitions
                 WHERE last_analyzed < ADD_MONTHS(TRUNC(SYSDATE),-1)
                 GROUP BY table_owner, table_name)
         WHERE num_old_parts > 0
         UNION ALL
        SELECT ''PARTITION_STALE_STATS'', owner, table_name,  ''Table partition''||table_name||''.''||partition_name||'' has stale stats''
          FROM table_and_part_stats
         WHERE stale_stats = ''YES''
           AND partition_name IS NOT NULL
         UNION ALL
        SELECT ''PARTITION_LOCKED_STATS'', owner, table_name,  ''Table partition''||table_name||''.''||partition_name||'' has locked stats''
          FROM table_and_part_stats
         WHERE stattype_locked IN (''ALL'',''DATA'')
           AND partition_name IS NOT NULL
         UNION ALL
        SELECT ''PARTITION_MISSING_STATS'', table_owner, table_name,  ''Table partition''||table_name||''.''||partition_name||'' has no stats''
          FROM partitions
         WHERE num_rows IS NULL
         UNION ALL 
        SELECT ''TABLE_STATS'', owner, table_name,  ''Table ''||table_name||'' stores 0 rows but accounts for more than 0 blocks''
          FROM tables
         WHERE num_rows = 0 and blocks > 0
         UNION ALL
        SELECT ''PARTITION_STATS'', table_owner, table_name||''.''||partition_name,  ''Table partition ''||table_name||''.''||partition_name||'' stores 0 rows but accounts for more than 0 blocks''
          FROM partitions
         WHERE num_rows = 0 and blocks > 0
         UNION ALL
        SELECT ''TABLE_STATS'', owner, table_name,  ''Table ''||table_name||'' seems empty (0 rows and 0 blocks)''
          FROM tables
         WHERE num_rows = 0 and blocks = 0
         UNION ALL  
        SELECT ''PARTITION_STATS'', table_owner, table_name||''.''||partition_name,  ''Table partition ''||table_name||''.''||partition_name||'' seems empty (0 rows and 0 blocks)''
          FROM partitions
         WHERE num_rows = 0 and blocks = 0      
         UNION ALL
        SELECT ''TABLE_DEGREE'', owner, table_name,  ''Table ''||table_name||'' has a non-default DEGREE (''||TRIM(degree)||'')''
          FROM tables
         WHERE degree <> ''1''
         UNION ALL
        SELECT ''INDEX_DEGREE'', tables.owner, tables.table_name, ''Table ''||tables.table_name||'' has ''||COUNT(*)||'' indexes with DEGREE different than the table itself''
          FROM tables, 
               indexes
         WHERE tables.owner = indexes.table_owner
           AND tables.table_name = indexes.table_name
           AND tables.degree <> indexes.degree
         GROUP BY tables.owner, tables.table_name
         HAVING COUNT(*) > 0
        )
 ORDER BY owner, table_name, scope DESC
';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
