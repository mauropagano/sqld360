DEF section_name = 'Performance';
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;


DEF title = 'SQL Performance Summary';
DEF main_table = 'GV$SQL';
BEGIN
  :sql_text := '
 SELECT /*+ &&top_level_hints. */
       source, plan_hash_value, SUM(executions) execs, ROUND(SUM(buffer_gets)/DECODE(SUM(executions),0,1,SUM(executions))) avg_buffer_gets, 
       ROUND(SUM(elapsed_time)/1e6/DECODE(SUM(executions),0,1,SUM(executions)),3) avg_elapsed_time_secs, ROUND(SUM(cpu_time)/1e6/DECODE(SUM(executions),0,1,SUM(executions)),3) avg_cpu_time_secs,
       ROUND(SUM(io_time)/1e6/DECODE(SUM(executions),0,1,SUM(executions)),3) avg_io_time_secs, ROUND(SUM(rows_processed)/DECODE(SUM(executions),0,1,SUM(executions)),3) avg_rows_processed,
       AVG(cost) avg_cost, MIN(first_load_time) first_load_time, MAX(last_load_time) last_load_time, MIN(optimizer_env_hash_value) min_cbo_env, max(optimizer_env_hash_value) max_cbo_env,
       MIN(min_dop) min_req_dop, MAX(max_dop) max_req_dop
  FROM (SELECT ''MEM'' source, a.plan_hash_value, executions, elapsed_time, cpu_time, rows_processed, buffer_gets, first_load_time, last_load_time, optimizer_cost cost, optimizer_env_hash_value, min_dop, max_dop, user_io_wait_time io_time
          FROM gv$sql a,
               (SELECT plan_hash_value, MIN(TO_NUMBER(extractValue(XMLType(other_xml),''/other_xml/info[@type="dop"]''))) min_dop, 
                       MAX(TO_NUMBER(extractValue(XMLType(other_xml),''/other_xml/info[@type="dop"]''))) max_dop
                  FROM gv$sql_plan
                 WHERE sql_id = ''&&sqld360_sqlid.''
                   AND other_xml IS NOT NULL
                 GROUP BY plan_hash_value) dop
         WHERE sql_id = ''&&sqld360_sqlid.''
           AND a.plan_hash_value = dop.plan_hash_value(+)
        UNION ALL
        SELECT ''HIST'' source, a.plan_hash_value, executions_delta executions, elapsed_time_delta elapsed_time, cpu_time_delta cpu_time, rows_processed_delta rows_processed,
               buffer_gets_delta buffer_gets, null first_load_time, null last_load_time, optimizer_cost, optimizer_env_hash_value, min_dop, max_dop, iowait_delta
          FROM dba_hist_sqlstat a,
               (SELECT plan_hash_value, MIN(TO_NUMBER(extractValue(XMLType(other_xml),''/other_xml/info[@type="dop"]''))) min_dop, 
                       MAX(TO_NUMBER(extractValue(XMLType(other_xml),''/other_xml/info[@type="dop"]''))) max_dop
                  FROM dba_hist_sql_plan
                 WHERE sql_id = ''&&sqld360_sqlid.''
                   AND ''&&diagnostics_pack.'' = ''Y''
                   AND other_xml IS NOT NULL
                 GROUP BY plan_hash_value) dop  
         WHERE sql_id = ''&&sqld360_sqlid.''
           AND ''&&diagnostics_pack.'' = ''Y''
           AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
           AND a.plan_hash_value = dop.plan_hash_value(+))
 GROUP BY source, plan_hash_value
';
END;
/
@@sqld360_9a_pre_one.sql



COL sql_text NOPRI
COL sql_fulltext NOPRI
COL optimizer_env NOPRI
COL bind_data NOPRI

DEF title = 'SQL Statistics from Memory';
DEF main_table = 'GV$SQL';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, child_number
';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI
COL sql_fulltext PRI
COL optimizer_env PRI
COL bind_data PRI



COL sql_text NOPRI
COL sql_fulltext NOPRI

DEF title = 'SQL Statistics from Memory (SQLSTATS)';
DEF main_table = 'GV$SQLSTATS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sqlstats
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id
';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI
COL sql_fulltext PRI



DEF title = 'SQL Plan Statistics from Memory';
DEF main_table = 'GV$SQL_PLAN_STATISTICS_ALL';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_plan_statistics_all
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, plan_hash_value, child_number, id
';
END;
/
@@sqld360_9a_pre_one.sql


COL sql_text NOPRI
COL sql_fulltext NOPRI

DEF title = 'SQL Plan Statistics from Memory (SQLSTATS)';
DEF main_table = 'GV$SQLSTATS_PLAN_HASH';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sqlstats_plan_hash
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, plan_hash_value
';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI
COL sql_fulltext PRI


COL bind_data NOPRI

DEF title = 'SQL Statistics from History';
DEF main_table = 'DBA_HIST_SQLSTAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       sn.begin_interval_time, sn.end_interval_time,
       s.*
  FROM dba_hist_sqlstat s,
       dba_hist_snapshot sn
 WHERE s.snap_id = sn.snap_id
   AND s.instance_number = sn.instance_number
   AND s.sql_id = ''&&sqld360_sqlid.''
   AND ''&&diagnostics_pack.'' = ''Y''
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
 ORDER BY s.snap_id desc, s.instance_number, s.plan_hash_value
';
END;
/
@@sqld360_9a_pre_one.sql

COL bind_data PRI



DEF title = 'SQL Plan Statistics from History';
DEF main_table = 'DBA_HIST_SQL_PLAN';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_hist_sql_plan
 WHERE sql_id = ''&&sqld360_sqlid.''
   AND ''&&diagnostics_pack.'' = ''Y''
 ORDER BY plan_hash_value, id
';
END;
/
@@sqld360_9a_pre_one.sql
