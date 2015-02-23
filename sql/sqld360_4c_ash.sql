-- PLAN_TABLE / ASH columns mapping
-- statement_id     'SQLD360_ASH_DATA'
-- timestamp        sample_time
-- remarks,         sql_id
-- cardinality      snap_id 
-- search_columns   dbid
-- operation        sql_plan_operation  skipped in 10g
-- options          sql_plan_options  skipped in 10g
-- object_instance  current_obj#
-- object_node      nvl(event,'ON CPU')
-- position         instance_number
-- cost             PHV
-- other_tag        wait_class
-- id               sql_plan_line_id   skipped in 10g
-- partition_id     sql_exec_id
-- cpu_cost         session_id
-- io_cost          session_serial#
-- parent_id        sample_id

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

COL db_name FOR A9;
COL host_name FOR A64;
COL instance_name FOR A16;
COL db_unique_name FOR A30;
COL platform_name FOR A101;
COL version FOR A17;

COL elapsed_time FOR 999999990;
COL cpu_time FOR 999999990;

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Elapsed Time per recent executions';
DEF foot = 'Data rounded to the 1 second';

BEGIN
  :sql_text_backup := '
SELECT cpu_cost session_id,
       io_cost session_serial#,
       partition_id sql_exec_id,
       TO_CHAR(MIN(timestamp), ''YYYY-MM-DD HH24:MI:SS'')  start_time,
       TO_CHAR(MAX(timestamp), ''YYYY-MM-DD HH24:MI:SS'')  end_time,
	   MIN(cost) plan_hash_value,
       COUNT(*) elapsed_time, 
       SUM(CASE WHEN object_node = ''ON CPU'' THEN 1 ELSE 0 END) cpu_time
  FROM plan_table
 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''
   AND position =  @instance_number@
   AND remarks = ''&&sqld360_sqlid.''
   AND ''&&diagnostics_pack.'' = ''Y''
 GROUP BY partition_id, cpu_cost, io_cost
 ORDER BY
       TO_CHAR(MIN(timestamp), ''YYYY-MM-DD HH24:MI:SS''),
       partition_id
';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Elapsed Time per recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Elapsed Time per recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Elapsed Time per recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Elapsed Time per recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Elapsed Time per recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Elapsed Time per recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Elapsed Time per recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Elapsed Time per recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Elapsed Time per recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


------------------------------------------------
------------------------------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Elapsed Time per historical execution';
DEF foot = 'Data rounded to the 10 seconds';


BEGIN
  :sql_text_backup := '
SELECT cpu_cost session_id,
       io_cost session_serial#,
       partition_id sql_exec_id,
       TO_CHAR(MIN(timestamp), ''YYYY-MM-DD HH24:MI:SS'')  start_time,
       TO_CHAR(MAX(timestamp), ''YYYY-MM-DD HH24:MI:SS'')  end_time,
	   MIN(cost) plan_hash_value,
       SUM(10) elapsed_time, 
       SUM(CASE WHEN object_node = ''ON CPU'' THEN 10 ELSE 0 END) cpu_time
  FROM plan_table
 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''
   AND position =  @instance_number@
   AND remarks = ''&&sqld360_sqlid.''
   AND ''&&diagnostics_pack.'' = ''Y''
 GROUP BY partition_id, cpu_cost, io_cost
 ORDER BY
       TO_CHAR(MIN(timestamp), ''YYYY-MM-DD HH24:MI:SS''),
       partition_id
';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Elapsed Time per historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Elapsed Time per historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Elapsed Time per historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Elapsed Time per historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Elapsed Time per historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Elapsed Time per historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Elapsed Time per historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Elapsed Time per historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Elapsed Time per historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


------------------------------
------------------------------


DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'SQL Peak Demand for recent executions';
DEF foot = 'Data rounded to the 1 second'


BEGIN
  :sql_text_backup := '
SELECT 0 snap_id,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') begin_time, 
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       num_samples_min,
       num_samples_oncpu_min,
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
  FROM (SELECT TRUNC(end_time, ''hh24'') end_time,
               MAX(num_samples_min) num_samples_min,
               MAX(num_samples_oncpu_min) num_samples_oncpu_min
          FROM (SELECT TRUNC(timestamp, ''mi'') end_time,
                       COUNT(*) num_samples_min, 
                       SUM(CASE WHEN object_node = ''ON CPU'' THEN 1 ELSE 0 END) num_samples_oncpu_min
                  FROM plan_table
                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''
                   AND position =  @instance_number@
                   AND remarks = ''&&sqld360_sqlid.''
                   AND ''&&diagnostics_pack.'' = ''Y''
                 GROUP BY TRUNC(timestamp, ''mi''))
         GROUP BY TRUNC(end_time, ''hh24''))
 ORDER BY 3
';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';
DEF skip_lch = '';
DEF tit_01 = 'Peak Demand';
DEF tit_02 = 'Peak CPU Demand';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Peak Demand for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Peak Demand for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Peak Demand for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Peak Demand for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Peak Demand for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Peak Demand for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Peak Demand for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Peak Demand for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Peak Demand for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


------------------------------
------------------------------


DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'SQL Peak Demand for historical executions';
DEF foot = 'Data rounded to the 10 seconds'


BEGIN
  :sql_text_backup := '
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(num_samples_min,0) num_samples_min,
       NVL(num_samples_oncpu_min,0) num_samples_oncpu_min,
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
  FROM (SELECT snap_id,
               MAX(num_samples_min) num_samples_min,
               MAX(num_samples_oncpu_min) num_samples_oncpu_min
          FROM (SELECT cardinality snap_id,
                       TRUNC(timestamp, ''mi'') end_time,
                       SUM(10) num_samples_min, 
                       SUM(CASE WHEN object_node = ''ON CPU'' THEN 10 ELSE 0 END) num_samples_oncpu_min
                  FROM plan_table
                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''
                   AND position =  @instance_number@
                   AND remarks = ''&&sqld360_sqlid.''
                   AND ''&&diagnostics_pack.'' = ''Y''
                 GROUP BY cardinality, TRUNC(timestamp, ''mi''))
         GROUP BY snap_id) ash,
       dba_hist_snapshot b
 WHERE ash.snap_id(+) = b.snap_id
 ORDER BY 3
';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Peak Demand';
DEF tit_02 = 'Peak CPU Demand';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Peak Demand for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Peak Demand for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Peak Demand for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Peak Demand for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Peak Demand for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Peak Demand for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Peak Demand for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Peak Demand for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Peak Demand for historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql



------------------------------
------------------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Avg elapsed time per exec for recent executions';
DEF foot = 'Data rounded to the 1 second'

BEGIN
  :sql_text_backup := '
SELECT 0 snap_id,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') begin_time, 
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       avg_num_samples_min,
       med_num_samples_min,
       avg_num_samples_oncpu_min,
       med_num_samples_oncpu_min,
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
  FROM (SELECT end_time,
               MAX(avg_num_samples_min) avg_num_samples_min,
               MAX(med_num_samples_min) med_num_samples_min,
               MAX(avg_num_samples_oncpu_min) avg_num_samples_oncpu_min,
               MAX(med_num_samples_oncpu_min) med_num_samples_oncpu_min
          FROM (SELECT TRUNC(end_time, ''hh24'') end_time,
                       AVG(num_samples_min) avg_num_samples_min,
                       MEDIAN(num_samples_min) med_num_samples_min,
                       AVG(num_samples_oncpu_min) avg_num_samples_oncpu_min,
                       MEDIAN(num_samples_oncpu_min) med_num_samples_oncpu_min
                  FROM (SELECT TRUNC(timestamp, ''mi'') end_time,
                               partition_id sql_exec_id, 
                               COUNT(*) num_samples_min, 
                               SUM(CASE WHEN object_node = ''ON CPU'' THEN 1 ELSE 0 END) num_samples_oncpu_min
                          FROM plan_table
                         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''
                           AND position =  @instance_number@
                           AND remarks = ''&&sqld360_sqlid.''
                           AND ''&&diagnostics_pack.'' = ''Y''
                         GROUP BY TRUNC(timestamp, ''mi''), partition_id)
                 GROUP BY TRUNC(end_time, ''hh24''))
         GROUP BY end_time)
 ORDER BY 3
';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Average Elapsed Time';
DEF tit_02 = 'Median Elapsed Time';
DEF tit_03 = 'Average Time on CPU';
DEF tit_04 = 'Median Time on CPU';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg elapsed time per exec for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg elapsed time per exec for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql



------------------------------
------------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Avg elapsed time per exec for historical executions';
DEF foot = 'Data rounded to the 10 seconds'

BEGIN
  :sql_text_backup := '
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, ''YYYY-MM-DD HH24:MI'')  begin_time, 
       TO_CHAR(b.end_interval_time, ''YYYY-MM-DD HH24:MI'')  end_time,
       NVL(avg_num_samples_min,0) avg_num_samples_min,
       NVL(med_num_samples_min,0) med_num_samples_min,
       NVL(avg_num_samples_oncpu_min,0) avg_num_samples_oncpu_min,
       NVL(med_num_samples_oncpu_min,0) med_num_samples_oncpu_min,
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
  FROM (SELECT snap_id,
               MAX(avg_num_samples_min) avg_num_samples_min,
               MAX(med_num_samples_min) med_num_samples_min,
               MAX(avg_num_samples_oncpu_min) avg_num_samples_oncpu_min,
               MAX(med_num_samples_oncpu_min) med_num_samples_oncpu_min
          FROM (SELECT snap_id,
                       AVG(num_samples_min) avg_num_samples_min,
                       MEDIAN(num_samples_min) med_num_samples_min,
                       AVG(num_samples_oncpu_min) avg_num_samples_oncpu_min,
                       MEDIAN(num_samples_oncpu_min) med_num_samples_oncpu_min
                  FROM (SELECT cardinality snap_id,
                               TRUNC(timestamp, ''mi'') end_time,
                               partition_id sql_exec_id, 
                               SUM(10) num_samples_min, 
                               SUM(CASE WHEN object_node = ''ON CPU'' THEN 10 ELSE 0 END) num_samples_oncpu_min
                          FROM plan_table
                         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''
                           AND position =  @instance_number@
                           AND remarks = ''&&sqld360_sqlid.''
                           AND ''&&diagnostics_pack.'' = ''Y''
                         GROUP BY cardinality, TRUNC(timestamp, ''mi''), partition_id)
                 GROUP BY snap_id)
         GROUP BY snap_id) ash,
      dba_hist_snapshot b
 WHERE ash.snap_id(+) = b.snap_id
 ORDER BY 3
';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Average Elapsed Time';
DEF tit_02 = 'Median Elapsed Time';
DEF tit_03 = 'Average Time on CPU';
DEF tit_04 = 'Median Time on CPU';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg elapsed time per exec for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg elapsed time per exec for historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

