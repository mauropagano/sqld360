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

DEF section_name = 'ASH Raw Data';
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF title = 'Raw Data';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ 
       statement_id     source,
       search_columns   dbid,
       cardinality      snap_id,
       position         instance_number,
       parent_id        sample_id,
       timestamp        sample_time,
       partition_id     sql_exec_id,
       cpu_cost         session_id,
       io_cost          session_serial#,
       remarks          sql_id,
       cost             plan_hash_value,
       id               sql_plan_line_id,
       operation        sql_plan_operation,  
       options          sql_plan_options,  
       object_instance  current_obj#,
       object_node      cpu_or_event,
       other_tag        wait_class
  FROM plan_table
 WHERE remarks = ''&&sqld360_sqlid.''
   AND statement_id LIKE ''SQLD360_ASH_DATA%''
 ORDER BY timestamp,position
';
END;
/
@@sqld360_9a_pre_one.sql


