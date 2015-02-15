DEF section_name = 'SQL Impact';
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

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
-- parent_id        sample_id

@@sqld360_4b_awr.sql
@@sqld360_4c_ash.sql
--@@sqld360_4b_ash_byevent.sql
--@@&&skip_10g.sqld360_4c_ash_byplanline_event.sql
--@@sqld360_4d_ash_byplanline_obj_event.sql
