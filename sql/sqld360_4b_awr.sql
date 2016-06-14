DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = '&&sqld360_sqlid.';
DEF tit_02 = 'Total System Elapsed Time';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

COL db_name FOR A9;
COL host_name FOR A64;
COL instance_name FOR A16;
COL db_unique_name FOR A30;
COL platform_name FOR A101;
COL version FOR A17;

COL sql_elapsed FOR 999999990.000;
COL system_elapsed FOR 999999990.000;

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'SQL Execute Elapsed Time in secs';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(c.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(c.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       SUM(NVL(b.sql_val,0))/1000000 sql_elapsed,
       SUM(a.system_val)/1000000 system_elapsed, 
       TRUNC((SUM(NVL(b.sql_val,0))/SUM(a.system_val))*100,3) sql_impact_percentage,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, value-LAG(value,1) OVER (PARTITION BY instance_number ORDER BY snap_id ) system_val 
          FROM dba_hist_sys_time_model 
         WHERE stat_name LIKE ''sql execute%'') a,
       (SELECT snap_id, instance_number, elapsed_time_delta sql_val
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) c
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND a.instance_number = @instance_number@
   AND a.snap_id = c.snap_id
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = c.instance_number
   AND a.system_val > 0 -- skip the first snapshot where we can''t compute DELTA
                        -- and those where the value would be negative (restart in between)
 GROUP BY
       TO_CHAR(c.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(c.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(c.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Execute Time for Cluster';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Execute Time for Instance 1';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Execute Time for Instance 2';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Execute Time for Instance 3';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Execute Time for Instance 4';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Execute Time for Instance 5';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Execute Time for Instance 6';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Execute Time for Instance 7';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Execute Time for Instance 8';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Elapsed Time';
DEF tit_02 = 'CPU Time';
DEF tit_03 = 'IO Wait Time';
DEF tit_04 = 'Cluster Wait Time';
DEF tit_05 = 'Application Wait Time';
DEF tit_06 = 'Concurrency Wait Time';
DEF tit_07 = 'Unaccounted Time';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

COL elapsed_time FOR 999999990.000;
COL cpu_time FOR 999999990.000;
COL io_time FOR 999999990.000;
COL cluster_time FOR 999999990.000;
COL application_time FOR 999999990.000;
COL concurrency_time FOR 999999990.000;
COL unaccounted_time FOR 999999990.000;


DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'SQL Execute Elapsed Time in secs';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       SUM(NVL(b.elapsed_time_delta,0))/1000000 elapsed_time,
       SUM(NVL(b.cpu_time_delta,0))/1000000 cpu_time, 
       SUM(NVL(b.iowait_delta,0))/1000000 io_time,
       SUM(NVL(b.clwait_delta,0))/1000000 cluster_time,
       SUM(NVL(b.apwait_delta,0))/1000000 application_time,
       SUM(NVL(b.ccwait_delta,0))/1000000 concurrency_time,
       (SUM(NVL(b.elapsed_time_delta,0)) - 
         (SUM(NVL(b.cpu_time_delta,0)) +
          SUM(NVL(b.iowait_delta,0))   +
          SUM(NVL(b.clwait_delta,0))   +
          SUM(NVL(b.apwait_delta,0))   +
          SUM(NVL(b.ccwait_delta,0)))
       ) / 1000000 unaccounted_time,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, 
               elapsed_time_delta, cpu_time_delta, iowait_delta, clwait_delta, apwait_delta, ccwait_delta 
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Execute Time by Wait Class for Cluster';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Execute Time by Wait Class for Instance 1';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Execute Time by Wait Class for Instance 2';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Execute Time by Wait Class for Instance 3';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Execute Time by Wait Class for Instance 4';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Execute Time by Wait Class for Instance 5';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Execute Time by Wait Class for Instance 6';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Execute Time by Wait Class for Instance 7';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Execute Time by Wait Class for Instance 8';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Buffer Gets/exec';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Buffer Gets per Execution';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(TRUNC(SUM(b.buffer_gets_total)/SUM(NVL(NULLIF(executions_total,0),1)),3),0) buffer_gets,
       0 dummy_02, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, buffer_gets_total, executions_total
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Buffer Gets/Execution for Cluster';
DEF abstract = 'Avg Buffer Gets/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Buffer Gets/Execution for Instance 1';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Buffer Gets/Execution for Instance 2';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Buffer Gets/Execution for Instance 3';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Buffer Gets/Execution for Instance 4';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Buffer Gets/Execution for Instance 5';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Buffer Gets/Execution for Instance 6';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Buffer Gets/Execution for Instance 7';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Buffer Gets/Execution for Instance 8';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Rows Processed/exec';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Rows Processed per Execution';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(TRUNC(SUM(b.rows_processed_total)/SUM(NVL(NULLIF(executions_total,0),1)),3),0) rows_processed,
       0 dummy_02, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, rows_processed_total, executions_total
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Rows Processed/Execution for Cluster';
DEF abstract = 'Avg Rows Processed/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Rows Processed/Execution for Instance 1';
DEF abstract = 'Avg Rows Processed/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Rows Processed/Execution for Instance 2';
DEF abstract = 'Avg Rows Processed/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Rows Processed/Execution for Instance 3';
DEF abstract = 'Avg Rows Processed/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Rows Processed/Execution for Instance 4';
DEF abstract = 'Avg Rows Processed/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Rows Processed/Execution for Instance 5';
DEF abstract = 'Avg Rows Processed/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Rows Processed/Execution for Instance 6';
DEF abstract = 'Avg Rows Processed/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Rows Processed/Execution for Instance 7';
DEF abstract = 'Avg Rows Processed/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Rows Processed/Execution for Instance 8';
DEF abstract = 'Avg Rows Processed/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Elapsed Time/exec';
DEF tit_02 = 'Avg CPU Time/exec';
DEF tit_03 = 'Avg IO Time/exec';
DEF tit_04 = 'Avg Cluster Time/exec';
DEF tit_05 = 'Avg Application Time/exec';
DEF tit_06 = 'Avg Concurrency Time/exec';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Elapsed Time per Execution in secs';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(TRUNC(SUM(b.elapsed_time_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) elapsed_time,
       NVL(TRUNC(SUM(b.cpu_time_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) cpu_time, 
       NVL(TRUNC(SUM(b.iowait_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) iowait,
       NVL(TRUNC(SUM(b.clwait_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) clwait,
       NVL(TRUNC(SUM(b.apwait_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) apwait,
       NVL(TRUNC(SUM(b.ccwait_total)/SUM(NVL(NULLIF(executions_total,0),1)/1e6),3),0) ccwait,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, elapsed_time_total, cpu_time_total, 
               iowait_total, clwait_total, apwait_total, ccwait_total, executions_total
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution for Cluster';
DEF abstract = 'Avg Elapsed Time/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution for Instance 1';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution for Instance 2';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution for Instance 3';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution for Instance 4';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution for Instance 5';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution for Instance 6';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution for Instance 7';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution for Instance 8';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Buffer Gets';
DEF tit_02 = 'Disk Reads';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Buffer gets and disk reads';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(SUM(b.buffer_gets_delta),0) buffer_gets,
       NVL(SUM(b.disk_reads_delta),0) physical_reads, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, buffer_gets_delta, disk_reads_delta
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total Buffer Gets for Cluster';
DEF abstract = 'Buffer gets and disk reads for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Buffer Gets for Instance 1';
DEF abstract = 'Buffer gets and disk reads for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Buffer Gets for Instance 2';
DEF abstract = 'Buffer gets and disk reads for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Buffer Gets for Instance 3';
DEF abstract = 'Buffer gets and disk reads for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Buffer Gets for Instance 4';
DEF abstract = 'Buffer gets and disk reads for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Buffer Gets for Instance 5';
DEF abstract = 'Buffer gets and disk reads for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Buffer Gets for Instance 6';
DEF abstract = 'Buffer gets and disk reads for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Buffer Gets per Instance 7';
DEF abstract = 'Buffer gets and disk reads for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Buffer Gets per Instance 8';
DEF abstract = 'Buffer gets and disk reads for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

------------------------------------
------------------------------------


DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Rows processed';
DEF tit_02 = 'Fetch Calls';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Rows processed and Fetch calls';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(SUM(b.rows_processed_delta),0) rows_processed,
       NVL(SUM(b.fetches_delta),0) fetch_calls, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, rows_processed_delta, fetches_delta
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total Rows Processed per for Cluster';
DEF abstract = 'Rows processed and fetch calls for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Rows Processed per for Instance 1';
DEF abstract = 'Rows processed and fetch calls for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Rows Processed per for Instance 2';
DEF abstract = 'Rows processed and fetch calls for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Rows Processed per for Instance 3';
DEF abstract = 'Rows processed and fetch calls for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Rows Processed per for Instance 4';
DEF abstract = 'Rows processed and fetch calls for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Rows Processed per for Instance 5';
DEF abstract = 'Rows processed and fetch calls for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Rows Processed per for Instance 6';
DEF abstract = 'Rows processed and fetch calls for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Rows Processed per for Instance 7';
DEF abstract = 'Rows processed and fetch calls for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Rows Processed per for Instance 8';
DEF abstract = 'Rows processed and fetch calls for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Executions';
DEF tit_02 = 'Parse Calls';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Executions and Parse calls';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(SUM(b.executions_delta),0) executions_delta,
       NVL(SUM(b.parse_calls_delta),0) parse_calls, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, executions_delta, parse_calls_delta
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total number of Executions for Cluster';
DEF abstract = 'Executions and parse calls for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total number of Executions for Instance 1';
DEF abstract = 'Executions and parse calls for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total number of Executions for Instance 2';
DEF abstract = 'Executions and parse calls for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total number of Executions for Instance 3';
DEF abstract = 'Executions and parse calls for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total number of Executions for Instance 4';
DEF abstract = 'Executions and parse calls for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total number of Executions for Instance 5';
DEF abstract = 'Executions and parse calls for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total number of Executions for Instance 6';
DEF abstract = 'Executions and parse calls for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total number of Executions per Instance 7';
DEF abstract = 'Executions and parse calls for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total number of Executions per Instance 8';
DEF abstract = 'Executions and parse calls for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';


------------------------------------
------------------------------------




------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Version Count';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Number of Versions';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       SUM(NVL(b.version_count,0)) version_count,
       0 dummy_02, 
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, version_count
          FROM dba_hist_sqlstat
         WHERE sql_id = ''&&sqld360_sqlid.'') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND ''&&diagnostics_pack.'' = ''Y''
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, ''YYYY-MM-DD HH24:MI''), 
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
 ORDER BY
       TO_CHAR(a.end_interval_time, ''YYYY-MM-DD HH24:MI'')
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Number of Child Cursors for Cluster';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Number of Child Cursors for Instance 1';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Number of Child Cursors for Instance 2';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Number of Child Cursors for Instance 3';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Number of Child Cursors for Instance 4';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Number of Child Cursors for Instance 5';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Number of Child Cursors for Instance 6';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Number of Child Cursors for Instance 7';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Number of Child Cursors for Instance 8';
DEF abstract = 'Number of Child Cursors'
DEF foot = 'Number of Child Cursors'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
