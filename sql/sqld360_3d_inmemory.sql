DEF section_id = '3d';
DEF section_name = 'In-Memory';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'In-Memory Area';
DEF main_table = 'GV$INMEMORY_AREA';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$inmemory_area
 ORDER BY inst_id, pool 
';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'In-Memory Segments';
DEF main_table = 'GV$IM_SEGMENTS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$im_segments
 WHERE (owner, segment_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = ''LIST_OF_TABLES'' AND remarks = ''&&sqld360_sqlid.'')
 ORDER BY inst_id, owner, segment_name, partition_name, segment_type
';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'In-Memory Column Level';
DEF main_table = 'GV$IM_COLUMN_LEVEL';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$im_column_level
 WHERE (owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = ''LIST_OF_TABLES'' AND remarks = ''&&sqld360_sqlid.'')
 ORDER BY inst_id, owner, table_name, segment_column_id 
';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
