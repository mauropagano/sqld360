DEF section_id = '4a';
DEF section_name = 'SQL Performance';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@@sqld360_4b_awr.sql
@@sqld360_4c_ash.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;