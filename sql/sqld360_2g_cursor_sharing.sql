DEF section_id = '2g';
DEF section_name = 'Cursor Sharing';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Non-sharing reasons';
DEF main_table = 'GV$SQL_SHARED_CURSOR';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_shared_cursor 
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, child_number
';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'ACS Histogram';
DEF main_table = 'GV$SQL_CS_HISTOGRAM';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_histogram 
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, child_number
';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql


DEF title = 'ACS Statistics';
DEF main_table = 'GV$SQL_CS_STATISTICS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_statistics 
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, child_number
';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql


DEF title = 'ACS Selectivity';
DEF main_table = 'GV$SQL_CS_SELECTIVITY';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_selectivity 
 WHERE sql_id = ''&&sqld360_sqlid.''
 ORDER BY inst_id, child_number
';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
