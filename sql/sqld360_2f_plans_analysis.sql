SPO &&one_spool_filename..html APP;
PRO </head>
@sql/sqld360_0d_html_header.sql
PRO <body>
PRO <h1><em>&&sqld360_conf_tool_page.SQLd360</a></em> &&sqld360_vYYNN.: SQL 360-degree view - &&section_id.. Plans Details Page &&sqld360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
PRO sqlid:&&sqld360_sqlid. dbname:&&database_name_short. version:&&db_version. host:&&host_hash. license:&&license_pack. days:&&history_days. today:&&sqld360_time_stamp.
PRO </pre>
PRO

PRO <table><tr class="main">


SET ECHO OFF FEEDBACK OFF TIMING OFF 
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;

EXEC :repo_seq := 1;


-- The following code sucks but it's the only "easy" (aka not spending too much time computing it) workaround for those 
--  systems where the same SQL ID has hundreds of PHV, we only provide deeper info for the top sqld360_num_plan_details by amount of data
--  Each row in GV$SQL, DBA_HIST counts 1 towards the total, each row in ASH counts 0.5 (so this approach still favors ASH a bit over GV$SQL / DBA_HIST)
BEGIN
  FOR i IN (SELECT plan_hash_value
              FROM (SELECT plan_hash_value, ROWNUM num_plans
                      FROM (SELECT SUM(num_rows) rows_per_phv, plan_hash_value
                              FROM (SELECT COUNT(*) num_rows, plan_hash_value
                                      FROM gv$sql
                                     WHERE sql_id = '&&sqld360_sqlid.'
                                     GROUP BY plan_hash_value
                                    UNION ALL
                                    SELECT COUNT(*) num_rows, plan_hash_value
                                      FROM dba_hist_sqlstat
                                     WHERE sql_id = '&&sqld360_sqlid.'
                                       AND '&&diagnostics_pack.' = 'Y'
                                     GROUP BY plan_hash_value
                                    UNION ALL
                                    SELECT SUM(0.5) num_rows, cost plan_hash_value
                                      FROM plan_table
                                     WHERE statement_id LIKE 'SQLD360_ASH_DATA%'
                                       AND '&&diagnostics_pack.' = 'Y'
                                       AND remarks = '&&sqld360_sqlid.'
                                     GROUP BY cost) 
                             GROUP BY plan_hash_value
                             ORDER BY 1 DESC)
                     WHERE ('&&sqld360_is_insert.' IS NULL AND plan_hash_value <> 0) OR ('&&sqld360_is_insert.' = 'Y'))
             WHERE num_plans <= &&sqld360_num_plan_details.)
  LOOP
    DBMS_OUTPUT.PUT_LINE('<td class="c">PHV '||i.plan_hash_value||'</td>');
  END LOOP;
END;
/

PRO </tr><tr class="main">
SPO OFF

-- this is to trick sqld360_9a_pre
DEF sqld360_main_report_bck = &&sqld360_main_report.
DEF sqld360_main_report = &&one_spool_filename.

-- reset the sequence since this is a different page
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SPO sqld360_plans_analysis_&&sqld360_sqlid._driver.sql
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;


DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

-- this is intentional, showing all the tables including the ones with no histograms
-- so it's easier to spot the ones with no histograms too
  FOR i IN (SELECT plan_hash_value
              FROM (SELECT plan_hash_value, ROWNUM num_plans
                      FROM (SELECT SUM(num_rows) rows_per_phv, plan_hash_value
                              FROM (SELECT COUNT(*) num_rows, plan_hash_value
                                      FROM gv$sql
                                     WHERE sql_id = '&&sqld360_sqlid.'
                                     GROUP BY plan_hash_value
                                    UNION ALL
                                    SELECT COUNT(*) num_rows, plan_hash_value
                                      FROM dba_hist_sqlstat
                                     WHERE sql_id = '&&sqld360_sqlid.'
                                       AND '&&diagnostics_pack.' = 'Y'
                                     GROUP BY plan_hash_value
                                    UNION ALL
                                    SELECT SUM(0.5) num_rows, cost plan_hash_value
                                      FROM plan_table
                                     WHERE statement_id LIKE 'SQLD360_ASH_DATA%'
                                       AND '&&diagnostics_pack.' = 'Y'
                                       AND remarks = '&&sqld360_sqlid.'
                                     GROUP BY cost) 
                             GROUP BY plan_hash_value
                             ORDER BY 1 DESC)
                     WHERE ('&&sqld360_is_insert.' IS NULL AND plan_hash_value <> 0) OR ('&&sqld360_is_insert.' = 'Y'))
             WHERE num_plans <= &&sqld360_num_plan_details.) 
  LOOP
    put('SET PAGES 50000');
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO <td>');
    put('SPO OFF');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO <h2>Execution Plan</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');

    put('DEF bubbleMaxValue = ''''');
    put('COL bubbleMaxValue NEW_V bubbleMaxValue');
    -- this is to make the chart a little larger
    put('SELECT NVL2(MAX(id), ''maxValue:''||TO_CHAR(MAX(id)+2)||'','' , '''') bubbleMaxValue ');
    put('  FROM (SELECT MAX(id) id');
    put('          FROM gv$sql_plan');
    put('         WHERE sql_id = ''&&sqld360_sqlid.''');
    put('           AND plan_hash_value ='||i.plan_hash_value);
    put('        UNION ALL');
    put('        SELECT MAX(id) id');
    put('          FROM dba_hist_sql_plan');
    put('         WHERE sql_id = ''&&sqld360_sqlid.''');
    put('           AND plan_hash_value ='||i.plan_hash_value);
    put('           AND ''&&diagnostics_pack.'' = ''Y'');');

    put('DEF bubbleSeries = ''series: {''''CPU'''': {color: ''''#00E600''''}, ''''I/O'''': {color: ''''#0000FF''''}, ''''Concurrency'''': {color: ''''#820000''''}, ''''Cluster'''': {color: ''''#C07F3F''''}, ''''Other'''': {color: ''''#FFFF00''''}, ''''Multiple'''': {color: ''''#CCFFFF''''}},''');

    put('----------------------------');

    put('DEF title=''Plan Tree for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_SQL_PLAN''');
    put('DEF skip_html=''Y''');
    put('DEF skip_text=''Y''');
    put('DEF skip_csv=''Y''');
    put('DEF skip_tch=''''');

    -- there is a slim risk of counting a sample twice (one more memory and one from history), ok for now
    put('COL treeColor NEW_V treeColor');
    --put('SELECT LISTAGG(treeColor,chr(10)) WITHIN GROUP (ORDER BY id) treeColor');
    
    
    -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
    put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
    put('INSERT INTO plan_table (statement_id, operation, options) SELECT ''SQLD360_TREECOLOR'', ''&&sqld360_sqlid.'', treeColor ');
    put('  FROM (SELECT plandata.adapt_id id,''data.setRowProperty(''||plandata.adapt_id||'', ''''style'''', ''''background:#FF''||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),''XXXX'')),2,''0'')||''00'''');'' treeColor');
    put('          FROM (SELECT NVL(id,0) id, COUNT(*) num_samples');
    put('                  FROM plan_table ');
    put('                 WHERE statement_id LIKE ''SQLD360_ASH_DATA%''');
    put('                   AND cost = '||i.plan_hash_value);
    put('                   AND remarks = ''&&sqld360_sqlid.''');
    put('                 GROUP BY NVL(id,0))  ashdata, ');
    put('                (SELECT sql_id, plan_hash_value, id, parent_id, dep, adapt_id, operation, options, object_name, skp ');
    put('                   FROM (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, skp ');
    -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)          
    put('                           FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, b.skp ');
    put('                                  FROM gv$sql_plan_statistics_all a, ');
    put('                                       (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
    put('                                          FROM gv$sql_plan_statistics_all a, ');
    put('                                               TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''/*/display_map/row''))) b ');
    put('                                         WHERE sql_id = ''&&sqld360_sqlid.''');
    put('                                           AND other_xml IS NOT NULL ');
    put('                                           AND plan_hash_value = '||i.plan_hash_value||') b ');
    put('                                 WHERE a.sql_id = ''&&sqld360_sqlid.''');
    put('                                   AND a.plan_hash_value = '||i.plan_hash_value||' ');
    put('                                   AND a.id = b.stepid(+) ');
    put('                                   AND (b.skp = 0 OR b.skp IS NULL)) ');
    put('                         UNION ');
    put('                         SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation,a.options,a.object_name, b.skp ');
    put('                           FROM dba_hist_sql_plan a, ');
    put('                                (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
    put('                                   FROM dba_hist_sql_plan a, ');
    put('                                        TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''/*/display_map/row''))) b ');
    put('                                  WHERE sql_id = ''&&sqld360_sqlid.''');
    put('                                    AND other_xml IS NOT NULL ');
    put('                                    AND plan_hash_value = '||i.plan_hash_value||' ) b ');
    put('                           WHERE a.sql_id = ''&&sqld360_sqlid.''');
    put('                             AND a.plan_hash_value = '||i.plan_hash_value||' ');
    put('                             AND a.id = b.stepid(+) ');
    put('                             AND NOT EXISTS (SELECT 1 ');
    put('                                               FROM gv$sql_plan_statistics_all c');
    put('                                              WHERE c.plan_hash_value =  '||i.plan_hash_value||' ');
    put('                                                AND c.sql_id = ''&&sqld360_sqlid.'' ');
    put('                                                AND a.sql_id = c.sql_id ');
    put('                                                AND a.plan_hash_value = c.plan_hash_value) '); 
    put('                             AND (b.skp = 0 OR b.skp IS NULL)) ');
    put('                   ORDER BY id) plandata ');
    put(' WHERE plandata.id = ashdata.id ');
    put(');');

    put('BEGIN');
    put(' :sql_text := ''');
    put('WITH ashdata AS (SELECT NVL(id,0) id, COUNT(*) num_samples');
    put('                   FROM plan_table ');
    put('                  WHERE statement_id LIKE ''''SQLD360_ASH_DATA%''''');
    put('                    AND cost = '||i.plan_hash_value);
    put('                    AND remarks = ''''&&sqld360_sqlid.''''');
    put('                  GROUP BY NVL(id,0))');
    put('SELECT ''''{v: ''''''''''''||plandata.adapt_id||'''''''''''',f: ''''''''''''||plandata.adapt_id||'''' - ''''||operation||'''' ''''||options||NVL2(object_name,''''<br>'''','''' '''')||object_name||''''''''''''}'''' id, ');
    put('       parent_id, SUBSTR(''''Step ID: ''''||plandata.adapt_id||'''' (ASH Step ID: ''''||plandata.id||'''')\nASH Samples: ''''||NVL(ashdata.num_samples,0)||'''' (''''||TRUNC(100*NVL(RATIO_TO_REPORT(ashdata.num_samples) OVER (),0),2)||''''%)''''|| ');
    put('                  NVL2(access_predicates,''''\n\nAccess Predicates: ''''||access_predicates,'''''''')||NVL2(filter_predicates,''''\n\nFilter Predicates: ''''||filter_predicates,''''''''),1,4000), plandata.adapt_id id3');
    put('  FROM (SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates '); 
    put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
    put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
    put('                                     FROM gv$sql_plan_statistics_all a, ');
    put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
    put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
    put('                                      AND other_xml IS NOT NULL ');
    put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
    put('                 plan_all AS (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, access_predicates, filter_predicates, skp ');
    -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)    
    put('                                FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp ');
    put('                                        FROM  (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, ');
    put('                                                      REPLACE(access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, ');
    -- the RANK here is to handle same PHV with different predicate ordering    
    put('                                                      RANK() OVER (ORDER BY inst_id, child_number) rnk ');
    put('                                                 FROM gv$sql_plan_statistics_all ');
    put('                                                WHERE sql_id = ''''&&sqld360_sqlid.'''' ');
    put('                                                  AND plan_hash_value = '||i.plan_hash_value||') a, ');
    put('                                             skp_steps b ');
    put('                                       WHERE a.rnk = 1');
    put('                                         AND a.id = b.stepid(+) ');
    put('                                         AND (b.skp = 0 OR b.skp IS NULL) ');
    put('                                       ORDER BY a.id)) ');
    put('                SELECT dep, adapt_id, id, '); 
    put('                       (SELECT MAX(adapt_id) ');
    put('                          FROM plan_all b ');
    put('                         WHERE a.dep-1 = b.dep'); 
    put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
    put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
    put('                  FROM plan_all a)');
    put('        UNION ');
    put('        SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates ');  
    put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
    put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
    put('                                     FROM dba_hist_sql_plan a, ');
    put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
    put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
    put('                                      AND other_xml IS NOT NULL ');
    put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
    put('                 plan_all AS (SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep,'); 
    put('                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, REPLACE(a.access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(a.filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, b.skp');
    put('                                FROM dba_hist_sql_plan a, skp_steps b ');
    put('                               WHERE a.sql_id = ''''&&sqld360_sqlid.''''');
    put('                                 AND a.plan_hash_value = '||i.plan_hash_value||'');
    put('                                 AND a.id = b.stepid(+) ');
    put('                                 AND (b.skp = 0 OR b.skp IS NULL) ');
    put('                               ORDER BY a.id) ');
    put('                SELECT dep, adapt_id, id, '); 
    put('                       (SELECT MAX(adapt_id) ');
    put('                          FROM plan_all b ');
    put('                         WHERE a.dep-1 = b.dep'); 
    put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
    put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
    put('                  FROM plan_all a');
    put('                 WHERE NOT EXISTS (SELECT 1 ');
    put('                             FROM gv$sql_plan_statistics_all ');
    put('                            WHERE plan_hash_value =  '||i.plan_hash_value||'');
    put('                              AND sql_id = ''''&&sqld360_sqlid.'''')');
    put('           AND ''''&&diagnostics_pack.'''' = ''''Y'''')) plandata,');
    put('       ashdata');
    put(' WHERE ashdata.id(+) = plandata.id');
    put(' ORDER BY plandata.id');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>');
    put('PRO <h2>Elapsed Time</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');

    put('DEF title=''Avg et/exec for recent execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Elapsed Time in secs''');
    put('DEF tit_01 = ''Average Elapsed Time''');
    put('DEF tit_02 = ''Average Time on CPU''');
    put('DEF tit_03 = ''Average DB Time''');
    put('DEF tit_04 = ''Min Elapsed Time''');
    put('DEF tit_05 = ''Max Elapsed Time''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(start_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(start_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       avg_et,');
    put('       avg_cpu_time,');
    put('       avg_db_time,');
    put('       min_et,');
    put('       max_et,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT start_time,');
    put('               TRUNC(AVG(et),2) avg_et,');
    put('               TRUNC(AVG(cpu_time),2) avg_cpu_time,');
    put('               TRUNC(AVG(db_time),2) avg_db_time,');
    put('               TRUNC(MIN(et),2) min_et,');
    put('               TRUNC(MAX(et),2) max_et');
    put('          FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),''''YYYYMMDDHH24MI'''') start_time,');
    put('                       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position)||''''-''''||'); 
    put('                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost)||''''-''''||'); 
    put('                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost)||''''-''''||');
    put('                        NVL(partition_id,0)||''''-''''||NVL(distribution,''''x'''') uniq_exec,'); 
    put('                       1+86400*(MAX(timestamp)-MIN(timestamp)) et,'); 
    put('                       SUM(CASE WHEN object_node = ''''ON CPU'''' THEN 1 ELSE 0 END) cpu_time,'); 
    put('                       COUNT(*) db_time'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                   AND cost =  '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('                   AND partition_id IS NOT NULL');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY TO_DATE(SUBSTR(distribution,1,12),''''YYYYMMDDHH24MI''''),');
    put('                          NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position)||''''-''''||'); 
    put('                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost)||''''-''''||'); 
    put('                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost)||''''-''''||');
    put('                           NVL(partition_id,0)||''''-''''||NVL(distribution,''''x''''))');
    put('          GROUP BY start_time)');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Avg et/exec for historical execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Elapsed Time in secs''');
    put('DEF tit_01 = ''Average Elapsed Time''');
    put('DEF tit_02 = ''Average Time on CPU''');
    put('DEF tit_03 = ''Average DB Time''');
    put('DEF tit_04 = ''Min Elapsed Time''');
    put('DEF tit_05 = ''Max Elapsed Time''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT b.snap_id snap_id,');
    put('       TO_CHAR(b.begin_interval_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(b.end_interval_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(avg_et,0) avg_et,');
    put('       NVL(avg_cpu_time,0) avg_cpu_time,');
    put('       NVL(avg_db_time,0) avg_db_time,');
    put('       NVL(min_et,0) min_et,');
    put('       NVL(max_et,0) max_et,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT snap_id,');
    put('               TRUNC(MAX(avg_et),2) avg_et,');
    put('               TRUNC(MAX(avg_cpu_time),2) avg_cpu_time,');
    put('               TRUNC(MAX(avg_db_time),2) avg_db_time,');
    put('               TRUNC(MAX(min_et),2) min_et,');
    put('               TRUNC(MAX(max_et),2) max_et');
    put('          FROM (SELECT start_time,');
    put('                       MIN(start_snap_id) snap_id,');
    put('                       AVG(et) avg_et,');
    put('                       AVG(cpu_time) avg_cpu_time,');
    put('                       AVG(db_time) avg_db_time,');
    put('                       MIN(et) min_et,');
    put('                       MAX(et) max_et');
    put('                  FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),''''YYYYMMDDHH24MI'''') start_time,');
    put('                               NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position)||''''-''''||'); 
    put('                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost)||''''-''''||'); 
    put('                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost)||''''-''''||');
    put('                                NVL(partition_id,0)||''''-''''||NVL(distribution,''''x'''') uniq_exec,'); 
    put('                               MIN(cardinality) start_snap_id,');
    put('                               10+86400*(MAX(timestamp)-MIN(timestamp)) et, ');
    put('                               SUM(CASE WHEN object_node = ''''ON CPU'''' THEN 10 ELSE 0 END) cpu_time,'); 
    put('                               SUM(10) db_time'); 
    put('                          FROM plan_table');
    put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                           AND partition_id IS NOT NULL');
    put('                           AND cost = '||i.plan_hash_value||'');
    put('                           AND remarks = ''''&&sqld360_sqlid.''''');
    put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                         GROUP BY TO_DATE(SUBSTR(distribution,1,12),''''YYYYMMDDHH24MI''''), ');
    put('                                  NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position)||''''-''''||'); 
    put('                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost)||''''-''''||'); 
    put('                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost)||''''-''''||');
    put('                                   NVL(partition_id,0)||''''-''''||NVL(distribution,''''x''''))');
    put('                 GROUP BY start_time)');
    put('         GROUP BY snap_id) ash,');
    put('      dba_hist_snapshot b');
    put(' WHERE ash.snap_id(+) = b.snap_id');
    put('   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>');
    put('PRO <h2>Resource Consumption</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');

    put('DEF title=''Peak PGA and TEMP usage for recent execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Bytes''');
    put('DEF tit_01 = ''PGA Usage''');
    put('DEF tit_02 = ''TEMP Usage''');
    put('DEF tit_03 = ''''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       pga_allocated_min,');
    put('       temp_space_allocated_min,');
    put('       0 dummy_03,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT TRUNC(end_time,''''mi'''') end_time,');
    put('               MAX(pga_allocated) pga_allocated_min,');
    put('               MAX(temp_space_allocated) temp_space_allocated_min');
    put('          FROM (SELECT timestamp end_time,');
    put('                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,'); 
    put('                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                   AND cost =  '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('                   AND partition_id IS NOT NULL');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY timestamp)');
    put('          GROUP BY TRUNC(end_time,''''mi''''))');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Peak PGA and TEMP usage for historical execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Bytes''');
    put('DEF tit_01 = ''PGA Usage''');
    put('DEF tit_02 = ''TEMP Usage''');
    put('DEF tit_03 = ''''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT b.snap_id snap_id,');
    put('       TO_CHAR(b.begin_interval_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(b.end_interval_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(pga_allocated_hour,0) pga_allocated_hour,');
    put('       NVL(temp_space_allocated_hour,0) temp_space_allocated_hour,');
    put('       0 dummy_03,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT snap_id,');
    put('               MAX(pga_allocated) pga_allocated_hour,');
    put('               MAX(temp_space_allocated) temp_space_allocated_hour');
    put('          FROM (SELECT cardinality snap_id,');
    put('                       timestamp end_time,'); 
    put('                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,');
    put('                       SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated');
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                   AND cost = '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.''''');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY cardinality, timestamp)');
    put('         GROUP BY snap_id) ash,');
    put('      dba_hist_snapshot b');
    put(' WHERE ash.snap_id(+) = b.snap_id');
    put('   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

-- the result in case of PX might be a little misleading because some slaves could be not sampled
-- for few secs and then show up with a delta_time > 1 sec so the metrics should be split "backwards" in time
-- but that would be too expensive to compute and likely to provide little benefit
-- there should be no issue for serial execs

    put('DEF title=''Peak Read and Write I/O requests for recent execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Number of I/O requests''');
    put('DEF tit_01 = ''Read I/O Request''');
    put('DEF tit_02 = ''Write I/O Request''');
    put('DEF tit_03 = ''''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       read_io_requests_min,');
    put('       write_io_requests_min,');
    put('       0 dummy_03,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT TRUNC(end_time,''''mi'''') end_time,');
    put('               MAX(read_io_requests) read_io_requests_min,');
    put('               MAX(write_io_requests) write_io_requests_min');
    put('          FROM (SELECT timestamp end_time,');
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
    put('                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
    put('                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                   AND cost =  '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('                   AND partition_id IS NOT NULL');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY timestamp)');
    put('          GROUP BY TRUNC(end_time,''''mi''''))');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Peak Read and Write I/O requests for historical execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''Number of I/O requests''');
    put('DEF tit_01 = ''Read I/O Request''');
    put('DEF tit_02 = ''Write I/O Request''');
    put('DEF tit_03 = ''''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT b.snap_id snap_id,');
    put('       TO_CHAR(b.begin_interval_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(b.end_interval_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(read_io_requests_hour,0) read_io_requests_hour,');
    put('       NVL(write_io_requests_hour,0) write_io_requests_hour,');
    put('       0 dummy_03,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT snap_id,');
    put('               MAX(read_io_requests) read_io_requests_hour,');
    put('               MAX(write_io_requests) write_io_requests_hour');
    put('          FROM (SELECT cardinality snap_id,');
    put('                       timestamp end_time,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
    put('                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
    put('                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                   AND cost = '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.''''');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY cardinality, timestamp)');
    put('         GROUP BY snap_id) ash,');
    put('      dba_hist_snapshot b');
    put(' WHERE ash.snap_id(+) = b.snap_id');
    put('   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Peak Read, Write and Interconnect I/O bytes for recent execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''I/O bytes''');
    put('DEF tit_01 = ''Read I/O Bytes''');
    put('DEF tit_02 = ''Write I/O Bytes''');
    put('DEF tit_03 = ''Interconnect I/O Bytes''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       read_io_bytes_min,');
    put('       write_io_bytes_min,');
    put('       interconnect_io_bytes_min,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT TRUNC(end_time,''''mi'''') end_time,');
    put('               MAX(read_io_bytes) read_io_bytes_min,');
    put('               MAX(write_io_bytes) write_io_bytes_min,');
    put('               MAX(interconnect_io_bytes) interconnect_io_bytes_min');
    put('          FROM (SELECT timestamp end_time,');
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
    put('                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
    put('                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)),0)/ ');
    put('                           ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                   AND cost =  '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('                   AND partition_id IS NOT NULL');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY timestamp)');
    put('          GROUP BY TRUNC(end_time,''''mi''''))');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Peak Read, Write and Interconnect I/O bytes for historical execs for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''LineChart''');
    put('DEF stacked = ''''');
    put('DEF vaxis = ''I/O bytes''');
    put('DEF tit_01 = ''Read I/O Bytes''');
    put('DEF tit_02 = ''Write I/O Bytes''');
    put('DEF tit_03 = ''Interconnect I/O Bytes''');
    put('DEF tit_04 = ''''');
    put('DEF tit_05 = ''''');
    put('DEF tit_06 = ''''');
    put('DEF tit_07 = ''''');
    put('DEF tit_08 = ''''');
    put('DEF tit_09 = ''''');
    put('DEF tit_10 = ''''');
    put('DEF tit_11 = ''''');
    put('DEF tit_12 = ''''');
    put('DEF tit_13 = ''''');
    put('DEF tit_14 = ''''');
    put('DEF tit_15 = ''''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT b.snap_id snap_id,');
    put('       TO_CHAR(b.begin_interval_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(b.end_interval_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(read_io_bytes_hour,0) read_io_requests_hour,');
    put('       NVL(write_io_bytes_hour,0) write_io_bytes_hour,');
    put('       NVL(interconnect_io_bytes_hour,0) interconnect_io_bytes_hour,');
    put('       0 dummy_04,');
    put('       0 dummy_05,');
    put('       0 dummy_06,');
    put('       0 dummy_07,');
    put('       0 dummy_08,');
    put('       0 dummy_09,');
    put('       0 dummy_10,');
    put('       0 dummy_11,');
    put('       0 dummy_12,');
    put('       0 dummy_13,');
    put('       0 dummy_14,');
    put('       0 dummy_15');
    put('  FROM (SELECT snap_id,');
    put('               MAX(read_io_bytes) read_io_bytes_hour,');
    put('               MAX(write_io_bytes) write_io_bytes_hour,');
    put('               MAX(interconnect_io_bytes) interconnect_io_bytes_hour');
    put('          FROM (SELECT cardinality snap_id,');
    put('                       timestamp end_time,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
    put('                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
    put('                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
    put('                       SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)),0)/ ');
    put('                               ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
    put('                  FROM plan_table');
    put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                   AND cost = '||i.plan_hash_value||'');
    put('                   AND remarks = ''''&&sqld360_sqlid.''''');
    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                 GROUP BY cardinality, timestamp)');
    put('         GROUP BY snap_id) ash,');
    put('      dba_hist_snapshot b');
    put(' WHERE ash.snap_id(+) = b.snap_id');
    put('   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.');
    put(' ORDER BY 3');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>');
    put('PRO <h2>Top N</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');

    put('DEF title=''Top 15 Wait events for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_pch=''''');
    put('DEF slices = ''15''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT cpu_or_event,');
    put('       num_samples,');
    put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
    put('       NULL dummy_01');
    put('  FROM (SELECT object_node cpu_or_event,');
    put('               count(*) num_samples');
    put('          FROM plan_table');
    put('         WHERE cost =  '||i.plan_hash_value||'');
    put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('         GROUP BY object_node'); 
    put('         ORDER BY 2 DESC)');
    put(' WHERE rownum <= 15');
    put(' ORDER BY 2 DESC');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Top 15 Objects accessed by PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_pch=''''');
    put('DEF slices = ''15''');
    put('BEGIN');
    put(' :sql_text := ''');
--    put('SELECT obj#,');
--    put('       num_samples,');
--    put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
--    put('       NULL dummy_01');
--    put('  FROM (SELECT NVL2(b.owner,b.owner||''''.''''||b.object_name,a.object_instance) obj#,');
--    put('               count(*) num_samples');
--    put('          FROM plan_table a,');
--    put('               dba_objects b');
--    put('         WHERE a.cost =  '||i.plan_hash_value||'');
--    put('           AND a.remarks = ''''&&sqld360_sqlid.'''''); 
--    put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
--    put('           AND a.object_instance = b.data_object_id(+)');
--    put('           AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
--    put('         GROUP BY NVL2(b.owner,b.owner||''''.''''||b.object_name,a.object_instance)'); 
--    put('         ORDER BY 2 DESC)');
--    put(' WHERE rownum <= 15');

--    put('SELECT object_name,');
--    put('       num_samples,');
--    put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
--    put('       NULL dummy_01');
--    put('  FROM (SELECT CASE WHEN data.object_name_sofar IS NOT NULL AND data.object_name_sofar <> ''''.'''' THEN data.object_name_sofar');
--    put('                    ELSE CASE WHEN o.owner||''''.''''||o.object_name <> ''''.'''' THEN o.owner||''''.''''||o.object_name'); 
--    put('                              ELSE TO_CHAR(data.obj#) ');
--    put('                         END ');
--    put('               END object_name,');
--    put('               data.num_samples');
--    put('          FROM (SELECT a.object_instance obj#,');
--    put('                       b.owner||''''.''''||b.object_name object_name_sofar,');
--    put('                       count(*) num_samples');
--    put('                  FROM plan_table a,');
--    put('                       dba_objects b');
--    put('                 WHERE a.cost =  '||i.plan_hash_value||'');
--    put('                   AND a.remarks = ''''&&sqld360_sqlid.'''''); 
--    put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
--    put('                   AND a.object_instance = b.object_id(+)');
--    put('                   AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
--    put('                 GROUP BY b.owner||''''.''''||b.object_name,a.object_instance) data,');
--    put('                dba_objects o');
--    put('         WHERE data.obj# = o.data_object_id(+)');
--    put('         ORDER BY 2 DESC)');
--    put(' WHERE rownum <= 15');

    put('SELECT data.obj#||');
    put('       CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
    put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
    put('       END data_object,');
    put('       num_samples,');
    put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
    put('       NULL dummy_01');
    put('  FROM (SELECT a.object_instance obj#,');
    put('               count(*) num_samples');
    put('          FROM plan_table a');
    put('         WHERE a.cost =  '||i.plan_hash_value||'');
    put('           AND a.remarks = ''''&&sqld360_sqlid.'''''); 
    put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('           AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
    put('         GROUP BY a.object_instance'); 
    put('         ORDER BY 2 DESC) data');
    put(' WHERE rownum <= 15');
    put(' ORDER BY 2 DESC');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Top 15 Plan Steps for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_pch=''''');
    put('DEF slices = ''15''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT operation,');
    put('       num_samples,');
    put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
    put('       NULL dummy_01');
    put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options operation,');
    put('               count(*) num_samples');
    put('          FROM plan_table');
    put('         WHERE cost =  '||i.plan_hash_value||'');
    put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options'); 
    put('         ORDER BY 2 DESC)');
    put(' WHERE rownum <= 15');
    put(' ORDER BY 2 DESC');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Top 15 Step/Event for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_pch=''''');
    put('DEF slices = ''15''');
    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT data.step||'''' ''''||CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
    put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
    put('       END||'''' / ''''||data.event  step_event,');
    put('       data.num_samples,');
    put('       TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2) percent,');
    put('       NULL dummy_01');
    --put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node step_event,');
    put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options step, object_instance obj#, object_node event,');    
    put('               count(*) num_samples');
    put('          FROM plan_table');
    put('         WHERE cost =  '||i.plan_hash_value||'');
    put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
    put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    --put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node'); 
    put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options, object_instance, object_node'); 
    put('         ORDER BY 4 DESC) data');
    put(' WHERE rownum <= 15');
    put(' ORDER BY 2 DESC');
    put(''';');
    put('END;');
    put('/ ');
    put('@sql/sqld360_9a_pre_one.sql');

    put('----------------------------');

    put('DEF title=''Top 15 Wait events over recent time for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''AreaChart''');
    put('DEF stacked = ''isStacked: true,''');
    put('DEF abstract = ''AAS (stacked) per top 15 wait events over time''');
    put('DEF vaxis = ''Average Active Sessions - AAS (stacked)''');

    -- this looks confusing but it actually has a reason :-)
    -- tit_n is used to show / hide the column in the chart (in case of nulls)
    -- evt_n is used as filter value (populated dynamically)
    -- eN  is used to show / hide the column in the resultset (in case of nulls)

    put('COL evt_01 NEW_V evt_01'); 
    put('COL evt_02 NEW_V evt_02'); 
    put('COL evt_03 NEW_V evt_03'); 
    put('COL evt_04 NEW_V evt_04'); 
    put('COL evt_05 NEW_V evt_05'); 
    put('COL evt_06 NEW_V evt_06'); 
    put('COL evt_07 NEW_V evt_07'); 
    put('COL evt_08 NEW_V evt_08'); 
    put('COL evt_09 NEW_V evt_09'); 
    put('COL evt_10 NEW_V evt_10'); 
    put('COL evt_11 NEW_V evt_11'); 
    put('COL evt_12 NEW_V evt_12'); 
    put('COL evt_13 NEW_V evt_13'); 
    put('COL evt_14 NEW_V evt_14'); 
    put('COL evt_15 NEW_V evt_15');
    put('COL tit_01 NEW_V tit_01'); 
    put('COL tit_02 NEW_V tit_02'); 
    put('COL tit_03 NEW_V tit_03'); 
    put('COL tit_04 NEW_V tit_04'); 
    put('COL tit_05 NEW_V tit_05'); 
    put('COL tit_06 NEW_V tit_06'); 
    put('COL tit_07 NEW_V tit_07'); 
    put('COL tit_08 NEW_V tit_08'); 
    put('COL tit_09 NEW_V tit_09'); 
    put('COL tit_10 NEW_V tit_10'); 
    put('COL tit_11 NEW_V tit_11'); 
    put('COL tit_12 NEW_V tit_12'); 
    put('COL tit_13 NEW_V tit_13'); 
    put('COL tit_14 NEW_V tit_14'); 
    put('COL tit_15 NEW_V tit_15'); 

    put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15 ');
    put('  FROM (SELECT 1 fake, object_node cpu_or_event,');
    put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
    put('          FROM plan_table'); 
    put('         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
    put('           AND cost = '||i.plan_hash_value);
    put('           AND remarks = ''&&sqld360_sqlid.''');
    put('         GROUP BY object_node) ash,');
    put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
    put(' WHERE ash.fake(+) = b.fake');
    put('   AND ranking <= 15');
    put('/');

    put('SET DEF @');

    put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
    put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
    put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
    put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
    put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
    put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
    put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
    put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
    put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
    put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
    put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
    put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
    put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
    put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
    put('       SUBSTR(''@evt_15.'',1,27) tit_15');
    put('  FROM DUAL');
    put('/');

    put('COL e01 NOPRI');
    put('COL e02 NOPRI');
    put('COL e03 NOPRI');
    put('COL e04 NOPRI');
    put('COL e05 NOPRI');
    put('COL e06 NOPRI');
    put('COL e07 NOPRI');
    put('COL e08 NOPRI');
    put('COL e09 NOPRI');
    put('COL e10 NOPRI');
    put('COL e11 NOPRI');
    put('COL e12 NOPRI');
    put('COL e13 NOPRI');
    put('COL e14 NOPRI');
    put('COL e15 NOPRI');

    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(aas_01,0) "e01@tit_01." ,');
    put('       NVL(aas_02,0) "e02@tit_02." ,');
    put('       NVL(aas_03,0) "e03@tit_03." ,');
    put('       NVL(aas_04,0) "e04@tit_04." ,');
    put('       NVL(aas_05,0) "e05@tit_05." ,');
    put('       NVL(aas_06,0) "e06@tit_06." ,');
    put('       NVL(aas_07,0) "e07@tit_07." ,');
    put('       NVL(aas_08,0) "e08@tit_08." ,');
    put('       NVL(aas_09,0) "e09@tit_09." ,');
    put('       NVL(aas_10,0) "e10@tit_10." ,');
    put('       NVL(aas_11,0) "e11@tit_11." ,');
    put('       NVL(aas_12,0) "e12@tit_12." ,');
    put('       NVL(aas_13,0) "e13@tit_13." ,');
    put('       NVL(aas_14,0) "e14@tit_14." ,');
    put('       NVL(aas_15,0) "e15@tit_15." ');
    put('  FROM (SELECT sample_time,');
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN aas ELSE NULL END) aas_01,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN aas ELSE NULL END) aas_02,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN aas ELSE NULL END) aas_03,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN aas ELSE NULL END) aas_04,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN aas ELSE NULL END) aas_05,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN aas ELSE NULL END) aas_06,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN aas ELSE NULL END) aas_07,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN aas ELSE NULL END) aas_08,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN aas ELSE NULL END) aas_09,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN aas ELSE NULL END) aas_10,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN aas ELSE NULL END) aas_11,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN aas ELSE NULL END) aas_12,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN aas ELSE NULL END) aas_13,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN aas ELSE NULL END) aas_14,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN aas ELSE NULL END) aas_15'); 
    put('          FROM (SELECT TRUNC(sample_time, ''''mi'''') sample_time,');
    put('                       cpu_or_event,');
    put('                       ROUND(SUM(num_sess)/60,3) aas');
    put('                  FROM (SELECT timestamp sample_time,');
    put('                               object_node cpu_or_event,'); 
    put('                               count(*) num_sess');
    put('                          FROM plan_table');
    put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
    put('                           AND remarks = ''''&&sqld360_sqlid.''''');
    put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                           AND cost = '||i.plan_hash_value);
    put('                           AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
    put('                                               ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
    put('                                               ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
    put('                         GROUP BY timestamp, object_node)');
    put('                 GROUP BY TRUNC(sample_time, ''''mi''''), cpu_or_event)');
    put('         GROUP BY sample_time)');
    put(' ORDER BY 3 ');
    put(''';');
    put('END;');
    put('/ ');

    put('SET DEF &');
    put('@sql/sqld360_9a_pre_one.sql');

    put('COL evt01_ PRI');
    put('COL evt02_ PRI');
    put('COL evt03_ PRI');
    put('COL evt04_ PRI');
    put('COL evt05_ PRI');
    put('COL evt06_ PRI');
    put('COL evt07_ PRI');
    put('COL evt08_ PRI');
    put('COL evt09_ PRI');
    put('COL evt10_ PRI');
    put('COL evt11_ PRI');
    put('COL evt12_ PRI');
    put('COL evt13_ PRI');
    put('COL evt14_ PRI');
    put('COL evt15_ PRI');

    put('UNDEF evt_01'); 
    put('UNDEF evt_02'); 
    put('UNDEF evt_03'); 
    put('UNDEF evt_04'); 
    put('UNDEF evt_05'); 
    put('UNDEF evt_06'); 
    put('UNDEF evt_07'); 
    put('UNDEF evt_08'); 
    put('UNDEF evt_09'); 
    put('UNDEF evt_10'); 
    put('UNDEF evt_11'); 
    put('UNDEF evt_12'); 
    put('UNDEF evt_13'); 
    put('UNDEF evt_14'); 
    put('UNDEF evt_15');    

    put('----------------------------');

    put('DEF title=''Top 15 Wait events over historical time for PHV '||i.plan_hash_value||'''');
    put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
    put('DEF skip_lch=''''');
    put('DEF chartype = ''AreaChart''');
    put('DEF stacked = ''isStacked: true,''');
    put('DEF abstract = ''AAS (stacked) per top 15 wait events over time''');
    put('DEF vaxis = ''Average Active Sessions - AAS (stacked)''');

    -- this looks confusing but it actually has a reason :-)
    -- tit_n is used to show / hide the column in the chart (in case of nulls)
    -- evt_n is used as filter value (populated dynamically)
    -- eN  is used to hosw / hide the column in the resultset (in case of nulls)

    put('COL evt_01 NEW_V evt_01'); 
    put('COL evt_02 NEW_V evt_02'); 
    put('COL evt_03 NEW_V evt_03'); 
    put('COL evt_04 NEW_V evt_04'); 
    put('COL evt_05 NEW_V evt_05'); 
    put('COL evt_06 NEW_V evt_06'); 
    put('COL evt_07 NEW_V evt_07'); 
    put('COL evt_08 NEW_V evt_08'); 
    put('COL evt_09 NEW_V evt_09'); 
    put('COL evt_10 NEW_V evt_10'); 
    put('COL evt_11 NEW_V evt_11'); 
    put('COL evt_12 NEW_V evt_12'); 
    put('COL evt_13 NEW_V evt_13'); 
    put('COL evt_14 NEW_V evt_14'); 
    put('COL evt_15 NEW_V evt_15');
    put('COL tit_01 NEW_V tit_01'); 
    put('COL tit_02 NEW_V tit_02'); 
    put('COL tit_03 NEW_V tit_03'); 
    put('COL tit_04 NEW_V tit_04'); 
    put('COL tit_05 NEW_V tit_05'); 
    put('COL tit_06 NEW_V tit_06'); 
    put('COL tit_07 NEW_V tit_07'); 
    put('COL tit_08 NEW_V tit_08'); 
    put('COL tit_09 NEW_V tit_09'); 
    put('COL tit_10 NEW_V tit_10'); 
    put('COL tit_11 NEW_V tit_11'); 
    put('COL tit_12 NEW_V tit_12'); 
    put('COL tit_13 NEW_V tit_13'); 
    put('COL tit_14 NEW_V tit_14'); 
    put('COL tit_15 NEW_V tit_15'); 

    put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
    put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
    put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
    put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
    put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
    put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
    put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
    put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
    put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
    put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
    put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
    put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
    put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
    put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
    put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15 ');
    put('  FROM (SELECT 1 fake, object_node cpu_or_event,');
    put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
    put('          FROM plan_table'); 
    put('         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
    put('           AND cost = '||i.plan_hash_value);
    put('           AND remarks = ''&&sqld360_sqlid.''');
    put('         GROUP BY object_node) ash,');
    put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
    put(' WHERE ash.fake(+) = b.fake');
    put('   AND ranking <= 15');
    put('/');

    put('SET DEF @');

    put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
    put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
    put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
    put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
    put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
    put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
    put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
    put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
    put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
    put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
    put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
    put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
    put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
    put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
    put('       SUBSTR(''@evt_15.'',1,27) tit_15');
    put('  FROM DUAL');
    put('/');

    put('COL e01 NOPRI');
    put('COL e02 NOPRI');
    put('COL e03 NOPRI');
    put('COL e04 NOPRI');
    put('COL e05 NOPRI');
    put('COL e06 NOPRI');
    put('COL e07 NOPRI');
    put('COL e08 NOPRI');
    put('COL e09 NOPRI');
    put('COL e10 NOPRI');
    put('COL e11 NOPRI');
    put('COL e12 NOPRI');
    put('COL e13 NOPRI');
    put('COL e14 NOPRI');
    put('COL e15 NOPRI');

    put('BEGIN');
    put(' :sql_text := ''');
    put('SELECT 0 snap_id,');
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') begin_time,'); 
    put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI'''') end_time,');
    put('       NVL(aas_01,0) "e01@tit_01." ,');
    put('       NVL(aas_02,0) "e02@tit_02." ,');
    put('       NVL(aas_03,0) "e03@tit_03." ,');
    put('       NVL(aas_04,0) "e04@tit_04." ,');
    put('       NVL(aas_05,0) "e05@tit_05." ,');
    put('       NVL(aas_06,0) "e06@tit_06." ,');
    put('       NVL(aas_07,0) "e07@tit_07." ,');
    put('       NVL(aas_08,0) "e08@tit_08." ,');
    put('       NVL(aas_09,0) "e09@tit_09." ,');
    put('       NVL(aas_10,0) "e10@tit_10." ,');
    put('       NVL(aas_11,0) "e11@tit_11." ,');
    put('       NVL(aas_12,0) "e12@tit_12." ,');
    put('       NVL(aas_13,0) "e13@tit_13." ,');
    put('       NVL(aas_14,0) "e14@tit_14." ,');
    put('       NVL(aas_15,0) "e15@tit_15." ');
    put('  FROM (SELECT sample_time,');
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN aas ELSE NULL END) aas_01,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN aas ELSE NULL END) aas_02,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN aas ELSE NULL END) aas_03,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN aas ELSE NULL END) aas_04,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN aas ELSE NULL END) aas_05,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN aas ELSE NULL END) aas_06,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN aas ELSE NULL END) aas_07,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN aas ELSE NULL END) aas_08,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN aas ELSE NULL END) aas_09,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN aas ELSE NULL END) aas_10,'); 
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN aas ELSE NULL END) aas_11,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN aas ELSE NULL END) aas_12,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN aas ELSE NULL END) aas_13,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN aas ELSE NULL END) aas_14,');  
    put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN aas ELSE NULL END) aas_15'); 
    put('          FROM (SELECT TRUNC(sample_time, ''''hh24'''') sample_time,');
    put('                       cpu_or_event,');
    put('                       ROUND(SUM(num_sess)*10/3600,3) aas');  -- *10 because the best we can do is assume the session spent the whole 10 secs on that event
    put('                  FROM (SELECT timestamp sample_time,');
    put('                               object_node cpu_or_event,'); 
    put('                               count(*) num_sess');
    put('                          FROM plan_table');
    put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
    put('                           AND remarks = ''''&&sqld360_sqlid.''''');
    put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
    put('                           AND cost = '||i.plan_hash_value);
    put('                           AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
    put('                                               ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
    put('                                               ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
    put('                         GROUP BY timestamp, object_node)');
    put('                 GROUP BY TRUNC(sample_time, ''''hh24''''), cpu_or_event)');
    put('         GROUP BY sample_time)');
    put(' ORDER BY 3 ');
    put(''';');
    put('END;');
    put('/ ');

    put('SET DEF &');
    put('@sql/sqld360_9a_pre_one.sql');

    put('COL evt01_ PRI');
    put('COL evt02_ PRI');
    put('COL evt03_ PRI');
    put('COL evt04_ PRI');
    put('COL evt05_ PRI');
    put('COL evt06_ PRI');
    put('COL evt07_ PRI');
    put('COL evt08_ PRI');
    put('COL evt09_ PRI');
    put('COL evt10_ PRI');
    put('COL evt11_ PRI');
    put('COL evt12_ PRI');
    put('COL evt13_ PRI');
    put('COL evt14_ PRI');
    put('COL evt15_ PRI');

    put('SET TERM ON');

    put('UNDEF evt_01'); 
    put('UNDEF evt_02'); 
    put('UNDEF evt_03'); 
    put('UNDEF evt_04'); 
    put('UNDEF evt_05'); 
    put('UNDEF evt_06'); 
    put('UNDEF evt_07'); 
    put('UNDEF evt_08'); 
    put('UNDEF evt_09'); 
    put('UNDEF evt_10'); 
    put('UNDEF evt_11'); 
    put('UNDEF evt_12'); 
    put('UNDEF evt_13'); 
    put('UNDEF evt_14'); 
    put('UNDEF evt_15'); 

    put('----------------------------');

    -- v1601, top SQL_EXEC_ID

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>');
    put('PRO <h2>Top Executions from memory</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');

    FOR j IN (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, TO_CHAR(min_sample_time, 'YYYYMMDDHH24MISS') min_sample_time, TO_CHAR(max_sample_time, 'YYYYMMDDHH24MISS') max_sample_time
                FROM (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start,  MIN(sample_time) min_sample_time, MAX(sample_time) max_sample_time, COUNT(*) num_samples
                        FROM (SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) inst_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#, 
                                     timestamp sample_time, 
                                     NVL(partition_id, FIRST_VALUE(partition_id IGNORE NULLS) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_id, 
                                     NVL(distribution, FIRST_VALUE(distribution IGNORE NULLS) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_start 
                                FROM plan_table 
                               WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                                 AND cost =  i.plan_hash_value
                                 AND '&&diagnostics_pack.' = 'Y'
                                 AND remarks = '&&sqld360_sqlid.')
                      GROUP BY inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start
                      ORDER BY num_samples DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_top_execs.) LOOP

       put('SPO &&one_spool_filename..html APP;');
       put('PRO SQL_EXEC_ID '||j.sql_exec_id||' from inst:'||j.inst_id||' sess:'||j.session_id||' serial#:'||j.session_serial#||' between '||TO_DATE(j.min_sample_time,'YYYYMMDDHH24MISS')||' and '||TO_DATE(j.max_sample_time,'YYYYMMDDHH24MISS')||' ');
       put('SPO OFF');

       put('----------------------------');

       put('DEF title=''Plan Tree for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_SQL_PLAN''');
       put('DEF skip_html=''Y''');
       put('DEF skip_text=''Y''');
       put('DEF skip_csv=''Y''');
       put('DEF skip_tch=''''');

       put('COL treeColor NEW_V treeColor');
       --put('SELECT LISTAGG(treeColor,chr(10)) WITHIN GROUP (ORDER BY id) treeColor');
       --put('  FROM (SELECT id,''data.setRowProperty(''||id||'', ''''style'''', ''''background:#FF''||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),''XXXX'')),2,''0'')||''00'''');'' treeColor');
       --put('          FROM (SELECT NVL(id,0) id, COUNT(*) num_samples');
       --put('                  FROM plan_table ');
       --put('                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
       --put('                   AND cost = '||i.plan_hash_value);
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       --put('                   AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       --put('                   AND remarks = ''&&sqld360_sqlid.''');
       --put('                 GROUP BY NVL(id,0))');
       --put(');');
       
       --put('SELECT LISTAGG(treeColor,chr(10)) WITHIN GROUP (ORDER BY id) treeColor');
    
    
       -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
       put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
       put('INSERT INTO plan_table (statement_id, operation, options) SELECT ''SQLD360_TREECOLOR'', ''&&sqld360_sqlid.'', treeColor ');
       put('  FROM (SELECT plandata.adapt_id id,''data.setRowProperty(''||plandata.adapt_id||'', ''''style'''', ''''background:#FF''||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),''XXXX'')),2,''0'')||''00'''');'' treeColor');
       put('          FROM (SELECT NVL(id,0) id, COUNT(*) num_samples');
       put('                  FROM plan_table ');
       put('                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('                   AND remarks = ''&&sqld360_sqlid.''');
       put('                 GROUP BY NVL(id,0))  ashdata, ');
       put('                (SELECT sql_id, plan_hash_value, id, parent_id, dep, adapt_id, operation, options, object_name, skp ');
       put('                   FROM (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, skp ');
       -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)          
       put('                           FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, b.skp ');
       put('                                  FROM gv$sql_plan_statistics_all a, ');
       put('                                       (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
       put('                                          FROM gv$sql_plan_statistics_all a, ');
       put('                                               table(xmlsequence(extract(xmltype(a.other_xml),''/*/display_map/row''))) b ');
       put('                                         WHERE sql_id = ''&&sqld360_sqlid.''');
       put('                                           AND other_xml IS NOT NULL ');
       put('                                           AND plan_hash_value = '||i.plan_hash_value||') b ');
       put('                                 WHERE a.sql_id = ''&&sqld360_sqlid.''');
       put('                                   AND a.plan_hash_value = '||i.plan_hash_value||' ');
       put('                                   AND a.id = b.stepid(+) ');
       put('                                   AND (b.skp = 0 OR b.skp IS NULL)) ');
       put('                         UNION ');
       put('                         SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation,a.options,a.object_name, b.skp ');
       put('                           FROM dba_hist_sql_plan a, ');
       put('                                (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
       put('                                   FROM dba_hist_sql_plan a, ');
       put('                                        table(xmlsequence(extract(xmltype(a.other_xml),''/*/display_map/row''))) b ');
       put('                                  WHERE sql_id = ''&&sqld360_sqlid.''');
       put('                                    AND other_xml IS NOT NULL ');
       put('                                    AND plan_hash_value = '||i.plan_hash_value||' ) b ');
       put('                           WHERE a.sql_id = ''&&sqld360_sqlid.''');
       put('                             AND a.plan_hash_value = '||i.plan_hash_value||' ');
       put('                             AND a.id = b.stepid(+) ');
       put('                             AND NOT EXISTS (SELECT 1 ');
       put('                                               FROM gv$sql_plan_statistics_all c');
       put('                                              WHERE c.plan_hash_value =  '||i.plan_hash_value||' ');
       put('                                                AND c.sql_id = ''&&sqld360_sqlid.'' ');
       put('                                                AND a.sql_id = c.sql_id ');
       put('                                                AND a.plan_hash_value = c.plan_hash_value) '); 
       put('                             AND (b.skp = 0 OR b.skp IS NULL)) ');
       put('                   ORDER BY id) plandata ');
       put(' WHERE plandata.id = ashdata.id ');
       put(');');

       put('BEGIN');
       put(' :sql_text := ''');
       put('WITH ashdata AS (SELECT NVL(id,0) id, COUNT(*) num_samples');
       put('                   FROM plan_table ');
       put('                  WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('                    AND cost = '||i.plan_hash_value);
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                    AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                    AND remarks = ''''&&sqld360_sqlid.''''');
       put('                  GROUP BY NVL(id,0))');
       put('SELECT ''''{v: ''''''''''''||plandata.adapt_id||'''''''''''',f: ''''''''''''||plandata.adapt_id||'''' - ''''||operation||'''' ''''||options||NVL2(object_name,''''<br>'''','''' '''')||object_name||''''''''''''}'''' id, ');
       put('       parent_id, SUBSTR(''''Step ID: ''''||plandata.adapt_id||'''' (ASH Step ID: ''''||plandata.id||'''')\nASH Samples: ''''||NVL(ashdata.num_samples,0)||'''' (''''||TRUNC(100*NVL(RATIO_TO_REPORT(ashdata.num_samples) OVER (),0),2)||''''%)''''|| ');
       put('                  NVL2(access_predicates,''''\n\nAccess Predicates: ''''||access_predicates,'''''''')||NVL2(filter_predicates,''''\n\nFilter Predicates: ''''||filter_predicates,''''''''),1,4000), plandata.adapt_id id3');
       put('  FROM (SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates '); 
       put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
       put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
       put('                                     FROM gv$sql_plan_statistics_all a, ');
       put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
       put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
       put('                                      AND other_xml IS NOT NULL ');
       put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
       put('                 plan_all AS (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, access_predicates, filter_predicates, skp ');
       -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)    
       put('                                FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp ');
       put('                                        FROM  (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, ');
       put('                                                      REPLACE(access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, ');
       -- the RANK here is to handle same PHV with different predicate ordering    
       put('                                                      RANK() OVER (ORDER BY inst_id, child_number) rnk ');
       put('                                                 FROM gv$sql_plan_statistics_all ');
       put('                                                WHERE sql_id = ''''&&sqld360_sqlid.'''' ');
       put('                                                  AND plan_hash_value = '||i.plan_hash_value||') a, ');
       put('                                             skp_steps b ');
       put('                                       WHERE a.rnk = 1');
       put('                                         AND a.id = b.stepid(+) ');
       put('                                         AND (b.skp = 0 OR b.skp IS NULL) ');
       put('                                       ORDER BY a.id)) ');
       put('                SELECT dep, adapt_id, id, '); 
       put('                       (SELECT MAX(adapt_id) ');
       put('                          FROM plan_all b ');
       put('                         WHERE a.dep-1 = b.dep'); 
       put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
       put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
       put('                  FROM plan_all a)');
       put('        UNION ');
       put('        SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates ');  
       put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
       put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
       put('                                     FROM dba_hist_sql_plan a, ');
       put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
       put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
       put('                                      AND other_xml IS NOT NULL ');
       put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
       put('                 plan_all AS (SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep,'); 
       put('                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, REPLACE(a.access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(a.filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, b.skp');
       put('                                FROM dba_hist_sql_plan a, skp_steps b ');
       put('                               WHERE a.sql_id = ''''&&sqld360_sqlid.''''');
       put('                                 AND a.plan_hash_value = '||i.plan_hash_value||'');
       put('                                 AND a.id = b.stepid(+) ');
       put('                                 AND (b.skp = 0 OR b.skp IS NULL) ');
       put('                               ORDER BY a.id) ');
       put('                SELECT dep, adapt_id, id, '); 
       put('                       (SELECT MAX(adapt_id) ');
       put('                          FROM plan_all b ');
       put('                         WHERE a.dep-1 = b.dep'); 
       put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
       put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
       put('                  FROM plan_all a');
       put('                 WHERE NOT EXISTS (SELECT 1 ');
       put('                             FROM gv$sql_plan_statistics_all ');
       put('                            WHERE plan_hash_value =  '||i.plan_hash_value||'');
       put('                              AND sql_id = ''''&&sqld360_sqlid.'''')');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y'''')) plandata,');
       put('       ashdata');
       put(' WHERE ashdata.id(+) = plandata.id');
       put(' ORDER BY plandata.id');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put('DEF title=''Plan Step IDs timeline for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_uch=''''');
       put('DEF abstract = ''Top SQL Plan Steps''');
       put('DEF vaxis = ''SQL Plan Step ID''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH, Y-axis report plan steps, size of the bubble is number of samples, color is major contributor (>50%) for bubble''');

       put('COL bubblesDetails NEW_V bubblesDetails');
       put('SELECT ''<br>Step Details<br>''||LISTAGG(step_details,''<br>'') WITHIN GROUP (ORDER BY id) bubblesDetails');
       put('          FROM (SELECT DISTINCT NVL(id,0) id, NVL(id,0)||'' - ''||operation||'' ''||options||'' (obj#:''||object_instance||'')'' step_details');
       put('                  FROM plan_table a ');
       put('                 WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND a.timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('                   AND remarks = ''&&sqld360_sqlid.''');
       put('               );');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       null,');
       put('       plan_line_id,');
       put('       CASE WHEN rtr_category > .5 THEN category ELSE ''''Multiple'''' END,');
       put('       num_samples');
       put('  FROM (SELECT end_time, plan_line_id, category, num_samples, rtr_category, ROW_NUMBER() OVER (PARTITION BY end_time, plan_line_id ORDER BY rtr_category DESC) rn_category');
       put('          FROM (SELECT end_time, plan_line_id, category, SUM(num_samples) OVER (PARTITION BY end_time, plan_line_id) num_samples, RATIO_TO_REPORT(num_samples) OVER (PARTITION BY end_time, plan_line_id) rtr_category');
       put('                  FROM (SELECT timestamp end_time, NVL(id,0) plan_line_id, ');
       put('                               CASE WHEN other_tag IS NULL THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END category,'); 
       put('                               COUNT(*) num_samples'); 
       put('                          FROM plan_table');
       put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('                           AND cost =  '||i.plan_hash_value||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('                           --AND partition_id IS NOT NULL');
       put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                         GROUP BY timestamp, NVL(id,0), CASE WHEN other_tag IS NULL THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END)');
       put('                 )');
       put('        )');
       put(' WHERE rn_category = 1');
       put(' ORDER BY end_time'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put('DEF title=''Top 15 Step/Event for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.step||'''' ''''||CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
       put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
       put('       END||'''' / ''''||data.event  step_event,');
       put('       data.num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       --put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node step_event,');
       put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options step, object_instance obj#, object_node event,'); 
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       --put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node');
       put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options, object_instance, object_node');  
       put('         ORDER BY 4 DESC) data');
       put(' WHERE rownum <= 15');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');    
    
       put('----------------------------');   

       put('DEF title=''Top 15 Wait events timeline for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''AreaChart''');
       put('DEF stacked = ''isStacked: true,''');
       put('DEF abstract = ''AS (stacked) per top 15 wait events''');
       put('DEF vaxis = ''Active Sessions - AS (stacked)''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH, Y-axis report Active Sessions at any time, not Average Active Sessions''');

       put('COL evt_01 NEW_V evt_01'); 
       put('COL evt_02 NEW_V evt_02'); 
       put('COL evt_03 NEW_V evt_03'); 
       put('COL evt_04 NEW_V evt_04'); 
       put('COL evt_05 NEW_V evt_05'); 
       put('COL evt_06 NEW_V evt_06'); 
       put('COL evt_07 NEW_V evt_07'); 
       put('COL evt_08 NEW_V evt_08'); 
       put('COL evt_09 NEW_V evt_09'); 
       put('COL evt_10 NEW_V evt_10'); 
       put('COL evt_11 NEW_V evt_11'); 
       put('COL evt_12 NEW_V evt_12'); 
       put('COL evt_13 NEW_V evt_13'); 
       put('COL evt_14 NEW_V evt_14'); 
       put('COL evt_15 NEW_V evt_15');
       put('COL tit_01 NEW_V tit_01'); 
       put('COL tit_02 NEW_V tit_02'); 
       put('COL tit_03 NEW_V tit_03'); 
       put('COL tit_04 NEW_V tit_04'); 
       put('COL tit_05 NEW_V tit_05'); 
       put('COL tit_06 NEW_V tit_06'); 
       put('COL tit_07 NEW_V tit_07'); 
       put('COL tit_08 NEW_V tit_08'); 
       put('COL tit_09 NEW_V tit_09'); 
       put('COL tit_10 NEW_V tit_10'); 
       put('COL tit_11 NEW_V tit_11'); 
       put('COL tit_12 NEW_V tit_12'); 
       put('COL tit_13 NEW_V tit_13'); 
       put('COL tit_14 NEW_V tit_14'); 
       put('COL tit_15 NEW_V tit_15'); 

       put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15 ');
       put('  FROM (SELECT 1 fake, object_node cpu_or_event,');
       put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
       put('          FROM plan_table'); 
       put('         WHERE statement_id = ''SQLD360_ASH_DATA_MEM''');
       put('           AND cost = '||i.plan_hash_value);
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('           AND remarks = ''&&sqld360_sqlid.''');
       put('         GROUP BY object_node) ash,');
       put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
       put(' WHERE ash.fake(+) = b.fake');
       put('   AND ranking <= 15');
       put('/');    

       put('SET DEF @');

       put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
       put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
       put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
       put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
       put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
       put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
       put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
       put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
       put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
       put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
       put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
       put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
       put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
       put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
       put('       SUBSTR(''@evt_15.'',1,27) tit_15');
       put('  FROM DUAL');
       put('/');

       put('COL e01 NOPRI');
       put('COL e02 NOPRI');
       put('COL e03 NOPRI');
       put('COL e04 NOPRI');
       put('COL e05 NOPRI');
       put('COL e06 NOPRI');
       put('COL e07 NOPRI');
       put('COL e08 NOPRI');
       put('COL e09 NOPRI');
       put('COL e10 NOPRI');
       put('COL e11 NOPRI');
       put('COL e12 NOPRI');
       put('COL e13 NOPRI');
       put('COL e14 NOPRI');
       put('COL e15 NOPRI');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       NVL(num_sess_01,0) "e01@tit_01." ,');
       put('       NVL(num_sess_02,0) "e02@tit_02." ,');
       put('       NVL(num_sess_03,0) "e03@tit_03." ,');
       put('       NVL(num_sess_04,0) "e04@tit_04." ,');
       put('       NVL(num_sess_05,0) "e05@tit_05." ,');
       put('       NVL(num_sess_06,0) "e06@tit_06." ,');
       put('       NVL(num_sess_07,0) "e07@tit_07." ,');
       put('       NVL(num_sess_08,0) "e08@tit_08." ,');
       put('       NVL(num_sess_09,0) "e09@tit_09." ,');
       put('       NVL(num_sess_10,0) "e10@tit_10." ,');
       put('       NVL(num_sess_11,0) "e11@tit_11." ,');
       put('       NVL(num_sess_12,0) "e12@tit_12." ,');
       put('       NVL(num_sess_13,0) "e13@tit_13." ,');
       put('       NVL(num_sess_14,0) "e14@tit_14." ,');
       put('       NVL(num_sess_15,0) "e15@tit_15." ');
       put('  FROM (SELECT sample_time,');
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN num_sess ELSE NULL END) num_sess_01,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN num_sess ELSE NULL END) num_sess_02,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN num_sess ELSE NULL END) num_sess_03,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN num_sess ELSE NULL END) num_sess_04,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN num_sess ELSE NULL END) num_sess_05,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN num_sess ELSE NULL END) num_sess_06,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN num_sess ELSE NULL END) num_sess_07,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN num_sess ELSE NULL END) num_sess_08,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN num_sess ELSE NULL END) num_sess_09,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN num_sess ELSE NULL END) num_sess_10,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN num_sess ELSE NULL END) num_sess_11,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN num_sess ELSE NULL END) num_sess_12,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN num_sess ELSE NULL END) num_sess_13,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN num_sess ELSE NULL END) num_sess_14,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN num_sess ELSE NULL END) num_sess_15'); 
       put('          FROM (SELECT timestamp sample_time,');
       put('                       object_node cpu_or_event,'); 
       put('                       count(*) num_sess');
       put('                  FROM plan_table');
       put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('                   AND remarks = ''''&&sqld360_sqlid.''''');
       put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                   AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
       put('                                       ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
       put('                                       ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
       put('                 GROUP BY timestamp, object_node)');
       put('         GROUP BY sample_time)');
       put(' ORDER BY 3 ');
       put(''';');
       put('END;');
       put('/ ');

       put('SET DEF &');
       put('@sql/sqld360_9a_pre_one.sql');

       put('COL evt01_ PRI');
       put('COL evt02_ PRI');
       put('COL evt03_ PRI');
       put('COL evt04_ PRI');
       put('COL evt05_ PRI');
       put('COL evt06_ PRI');
       put('COL evt07_ PRI');
       put('COL evt08_ PRI');
       put('COL evt09_ PRI');
       put('COL evt10_ PRI');
       put('COL evt11_ PRI');
       put('COL evt12_ PRI');
       put('COL evt13_ PRI');
       put('COL evt14_ PRI');
       put('COL evt15_ PRI');     

       put('UNDEF evt_01'); 
       put('UNDEF evt_02'); 
       put('UNDEF evt_03'); 
       put('UNDEF evt_04'); 
       put('UNDEF evt_05'); 
       put('UNDEF evt_06'); 
       put('UNDEF evt_07'); 
       put('UNDEF evt_08'); 
       put('UNDEF evt_09'); 
       put('UNDEF evt_10'); 
       put('UNDEF evt_11'); 
       put('UNDEF evt_12'); 
       put('UNDEF evt_13'); 
       put('UNDEF evt_14'); 
       put('UNDEF evt_15'); 

       put('----------------------------');

       put('DEF title=''DB Time by top 64 process for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''64''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.qcpx_process,');
       put('       data.num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       --put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node step_event,');
       put('  FROM (SELECT NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost  qcpx_process, ');   
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost   ');  
       put('         ORDER BY 2 DESC) data');
       put(' WHERE rownum <= 64');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');          

       put('----------------------------');

       put('DEF title=''PGA and TEMP usage for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Bytes''');
       put('DEF tit_01 = ''PGA Usage''');
       put('DEF tit_02 = ''TEMP Usage''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       pga_allocated,');
       put('       temp_space_allocated,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,'); 
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');    

       put('----------------------------');       

       put('DEF title=''Read and Write I/O requests for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Number of I/O requests''');
       put('DEF tit_01 = ''Read I/O Request''');
       put('DEF tit_02 = ''Write I/O Request''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_requests,');
       put('       write_io_requests,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');   

       put('----------------------------');

       put('DEF title=''Read, Write and Interconnect I/O bytes for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''V$ACTIVE_SESSION_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''I/O bytes''');
       put('DEF tit_01 = ''Read I/O Bytes''');
       put('DEF tit_02 = ''Write I/O Bytes''');
       put('DEF tit_03 = ''Interconnect I/O Bytes''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_bytes,');
       put('       write_io_bytes,');
       put('       interconnect_io_bytes,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_MEM''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       --put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');      

       put('DEF title = ''Raw Data for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''GV$ACTIVE_SESSION_HISTORY''');
       put('BEGIN ');
       put('  :sql_text := ''');
       put('SELECT /*+ &&top_level_hints. */ ');
       put('       statement_id     source,  ');
       put('       search_columns   dbid,    ');
       put('       cardinality      snap_id, ');
       put('       position         instance_number,  ');
       put('       parent_id        sample_id,        ');
       put('       TO_CHAR(timestamp, ''''YYYY-MM-DD/HH24:MI:SS'''')        sample_time, ');
       put('       partition_id     sql_exec_id, ');
       put('       TO_CHAR(TO_DATE(distribution,''''YYYYMMDDHH24MISS''''), ''''YYYY-MM-DD/HH24:MI:SS'''')  sql_exec_start, ');
       put('       cpu_cost         session_id,        ');
       put('       io_cost          session_serial#,   ');
       put('       bytes            user_id,           ');
       put('       remarks          sql_id,            ');
       put('       cost             plan_hash_value,   ');
       put('       id               sql_plan_line_id,  ');
       put('       operation        sql_plan_operation,');  
       put('       options          sql_plan_options,  '); 
       put('       object_node      cpu_or_event,      ');
       put('       other_tag        wait_class,        ');
       put('       TO_NUMBER(SUBSTR(partition_start,1,INSTR(partition_start,'''','''',1,1)-1)) seq#, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,1)+1,INSTR(partition_start,'''','''',1,2)-INSTR(partition_start,'''','''',1,1)-1) p1text, ');  
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,2)+1,INSTR(partition_start,'''','''',1,3)-INSTR(partition_start,'''','''',1,2)-1)) p1, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,3)+1,INSTR(partition_start,'''','''',1,4)-INSTR(partition_start,'''','''',1,3)-1) p2text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,4)+1,INSTR(partition_start,'''','''',1,5)-INSTR(partition_start,'''','''',1,4)-1)) p2, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,5)+1,INSTR(partition_start,'''','''',1,6)-INSTR(partition_start,'''','''',1,5)-1) p3text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,6)+1,INSTR(partition_start,'''','''',1,7)-INSTR(partition_start,'''','''',1,6)-1)) p3, ');
       put('       object_instance  current_obj#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,7)+1,INSTR(partition_start,'''','''',1,8)-INSTR(partition_start,'''','''',1,7)-1)) current_file#,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,8)+1,INSTR(partition_start,'''','''',1,9)-INSTR(partition_start,'''','''',1,8)-1)) current_block#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,9)+1,INSTR(partition_start,'''','''',1,10)-INSTR(partition_start,'''','''',1,9)-1)) current_row#,  ');
       put('       SUBSTR(partition_stop,1,INSTR(partition_stop,'''','''',1,1)-1) in_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,1)+1,INSTR(partition_stop,'''','''',1,2)-INSTR(partition_stop,'''','''',1,1)-1) in_hard_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,2)+1,INSTR(partition_stop,'''','''',1,3)-INSTR(partition_stop,'''','''',1,2)-1) in_sql_execution, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)) qc_instance_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)) qc_session_id,  ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)) qc_session_serial#, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,6)+1,INSTR(partition_stop,'''','''',1,7)-INSTR(partition_stop,'''','''',1,6)-1) blocking_session_status, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,7)+1,INSTR(partition_stop,'''','''',1,8)-INSTR(partition_stop,'''','''',1,7)-1)) blocking_session, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,8)+1,INSTR(partition_stop,'''','''',1,9)-INSTR(partition_stop,'''','''',1,8)-1)) blocking_session_serial#, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,9)+1,INSTR(partition_stop,'''','''',1,10)-INSTR(partition_stop,'''','''',1,9)-1)) blocking_inst_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,10)+1,INSTR(partition_stop,'''','''',1,11)-INSTR(partition_stop,'''','''',1,10)-1)) px_flags, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1)) pga_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1)) temp_space_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,10)+1,INSTR(partition_start,'''','''',1,11)-INSTR(partition_start,'''','''',1,10)-1)) tm_delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,11)+1,INSTR(partition_start,'''','''',1,12)-INSTR(partition_start,'''','''',1,11)-1)) tm_delta_cpu_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,12)+1)) tm_delta_db_time, '); 
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1)) delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)) delta_read_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)) delta_write_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)) delta_read_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)) delta_write_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)) delta_interconnect_io_bytes ');
       put('  FROM plan_table '); 
       put(' WHERE remarks = ''''&&sqld360_sqlid.'''' ');
       put('   AND statement_id = ''''SQLD360_ASH_DATA_MEM'''' ');
       put('   AND cost =  '||i.plan_hash_value||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put(' ORDER BY timestamp,position ');
       put(''';');
       put('END;');
       put('/');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');  

       put('SPO &&one_spool_filename..html APP;');
       put('PRO <br>');
       put('SPO OFF');

      
    END LOOP;

    put('SPO &&one_spool_filename..html APP;');
    put('PRO </ol>');
    put('PRO <h2>Top Executions from history</h2> ');
    put('SET DEF @');
    put('PRO <ol start="@report_sequence."> ');
    put('SET DEF &');
    put('SPO OFF');  

    FOR j IN (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, TO_CHAR(min_sample_time, 'YYYYMMDDHH24MISS') min_sample_time, TO_CHAR(max_sample_time, 'YYYYMMDDHH24MISS') max_sample_time
                FROM (SELECT inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start,  MIN(sample_time) min_sample_time, MAX(sample_time) max_sample_time, COUNT(*) num_samples
                        FROM (SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) inst_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,  
                                     NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#,  
                                     timestamp sample_time, 
                                     NVL(partition_id, FIRST_VALUE(partition_id IGNORE NULLS) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_id, 
                                     NVL(distribution, FIRST_VALUE(distribution IGNORE NULLS) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) sql_exec_start 
                                FROM plan_table 
                               WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                                 AND cost =  i.plan_hash_value
                                 AND '&&diagnostics_pack.' = 'Y'
                                 AND remarks = '&&sqld360_sqlid.')
                      GROUP BY inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start
                      ORDER BY num_samples DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_top_execs.) LOOP

       put('SPO &&one_spool_filename..html APP;');
       put('PRO SQL_EXEC_ID '||j.sql_exec_id||' from inst:'||j.inst_id||' sess:'||j.session_id||' serial#:'||j.session_serial#||' between '||TO_DATE(j.min_sample_time,'YYYYMMDDHH24MISS')||' and '||TO_DATE(j.max_sample_time,'YYYYMMDDHH24MISS')||' ');
       put('SPO OFF');

       put('----------------------------');

       put('DEF title=''Plan Tree for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_SQL_PLAN''');
       put('DEF skip_html=''Y''');
       put('DEF skip_text=''Y''');
       put('DEF skip_csv=''Y''');
       put('DEF skip_tch=''''');

       put('COL treeColor NEW_V treeColor');
       --put('SELECT LISTAGG(treeColor,chr(10)) WITHIN GROUP (ORDER BY id) treeColor');
       --put('  FROM (SELECT id,''data.setRowProperty(''||id||'', ''''style'''', ''''background:#FF''||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),''XXXX'')),2,''0'')||''00'''');'' treeColor');
       --put('          FROM (SELECT NVL(id,0) id, COUNT(*) num_samples');
       --put('                  FROM plan_table ');
       --put('                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       --put('                   AND cost = '||i.plan_hash_value);
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       --put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       --put('                   AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       --put('                   AND remarks = ''&&sqld360_sqlid.''');
       --put('                 GROUP BY NVL(id,0))');
       --put(');');
       
       --put('SELECT LISTAGG(treeColor,chr(10)) WITHIN GROUP (ORDER BY id) treeColor');
    
    
       -- not the most elegant soluton but SQL*Plus variable cannot store long string (aka long exec plans)
       put('DELETE plan_table WHERE statement_id = ''SQLD360_TREECOLOR'' AND operation = ''&&sqld360_sqlid.''; ');
       put('INSERT INTO plan_table (statement_id, operation, options) SELECT ''SQLD360_TREECOLOR'', ''&&sqld360_sqlid.'', treeColor ');put('  FROM (SELECT plandata.adapt_id id,''data.setRowProperty(''||plandata.adapt_id||'', ''''style'''', ''''background:#FF''||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),''XXXX'')),2,''0'')||''00'''');'' treeColor');
       put('          FROM (SELECT NVL(id,0) id, COUNT(*) num_samples');
       put('                  FROM plan_table ');
       put('                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('                   AND remarks = ''&&sqld360_sqlid.''');
       put('                 GROUP BY NVL(id,0))  ashdata, ');
       put('                (SELECT sql_id, plan_hash_value, id, parent_id, dep, adapt_id, operation, options, object_name, skp ');
       put('                   FROM (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, skp ');
       -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)          
       put('                           FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, b.skp ');
       put('                                  FROM gv$sql_plan_statistics_all a, ');
       put('                                       (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
       put('                                          FROM gv$sql_plan_statistics_all a, ');
       put('                                               table(xmlsequence(extract(xmltype(a.other_xml),''/*/display_map/row''))) b ');
       put('                                         WHERE sql_id = ''&&sqld360_sqlid.''');
       put('                                           AND other_xml IS NOT NULL ');
       put('                                           AND plan_hash_value = '||i.plan_hash_value||') b ');
       put('                                 WHERE a.sql_id = ''&&sqld360_sqlid.''');
       put('                                   AND a.plan_hash_value = '||i.plan_hash_value||' ');
       put('                                   AND a.id = b.stepid(+) ');
       put('                                   AND (b.skp = 0 OR b.skp IS NULL)) ');
       put('                         UNION ');
       put('                         SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation,a.options,a.object_name, b.skp ');
       put('                           FROM dba_hist_sql_plan a, ');
       put('                                (SELECT sql_id, plan_hash_value, extractvalue(value(b),''/row/@op'') stepid, extractvalue(value(b),''/row/@skp'') skp, extractvalue(value(b),''/row/@dep'') dep ');
       put('                                   FROM dba_hist_sql_plan a, ');
       put('                                        table(xmlsequence(extract(xmltype(a.other_xml),''/*/display_map/row''))) b ');
       put('                                  WHERE sql_id = ''&&sqld360_sqlid.''');
       put('                                    AND other_xml IS NOT NULL ');
       put('                                    AND plan_hash_value = '||i.plan_hash_value||' ) b ');
       put('                           WHERE a.sql_id = ''&&sqld360_sqlid.''');
       put('                             AND a.plan_hash_value = '||i.plan_hash_value||' ');
       put('                             AND a.id = b.stepid(+) ');
       put('                             AND NOT EXISTS (SELECT 1 ');
       put('                                               FROM gv$sql_plan_statistics_all c');
       put('                                              WHERE c.plan_hash_value =  '||i.plan_hash_value||' ');
       put('                                                AND c.sql_id = ''&&sqld360_sqlid.'' ');
       put('                                                AND a.sql_id = c.sql_id ');
       put('                                                AND a.plan_hash_value = c.plan_hash_value) '); 
       put('                             AND (b.skp = 0 OR b.skp IS NULL)) ');
       put('                   ORDER BY id) plandata ');
       put(' WHERE plandata.id = ashdata.id ');
       put(');');

       put('BEGIN');
       put(' :sql_text := ''');
       put('WITH ashdata AS (SELECT NVL(id,0) id, COUNT(*) num_samples');
       put('                   FROM plan_table ');
       put('                  WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('                    AND cost = '||i.plan_hash_value);
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                    AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                    AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                    AND remarks = ''''&&sqld360_sqlid.''''');
       put('                  GROUP BY NVL(id,0))');
       put('SELECT ''''{v: ''''''''''''||plandata.adapt_id||'''''''''''',f: ''''''''''''||plandata.adapt_id||'''' - ''''||operation||'''' ''''||options||NVL2(object_name,''''<br>'''','''' '''')||object_name||''''''''''''}'''' id, ');
       put('       parent_id, SUBSTR(''''Step ID: ''''||plandata.adapt_id||'''' (ASH Step ID: ''''||plandata.id||'''')\nASH Samples: ''''||NVL(ashdata.num_samples,0)||'''' (''''||TRUNC(100*NVL(RATIO_TO_REPORT(ashdata.num_samples) OVER (),0),2)||''''%)''''|| ');
       put('                  NVL2(access_predicates,''''\n\nAccess Predicates: ''''||access_predicates,'''''''')||NVL2(filter_predicates,''''\n\nFilter Predicates: ''''||filter_predicates,''''''''),1,4000), plandata.adapt_id id3');
       put('  FROM (SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates '); 
       put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
       put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
       put('                                     FROM gv$sql_plan_statistics_all a, ');
       put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
       put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
       put('                                      AND other_xml IS NOT NULL ');
       put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
       put('                 plan_all AS (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, access_predicates, filter_predicates, skp ');
       -- the DISTINCT here is to handle multiple child cursors with the same PHV (otherise the ROW_NUMBER makes them all distinct)    
       put('                                FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, a.access_predicates, a.filter_predicates, b.skp ');
       put('                                        FROM  (SELECT sql_id, plan_hash_value, id, parent_id, operation, options, object_name, ');
       put('                                                      REPLACE(access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, ');
       -- the RANK here is to handle same PHV with different predicate ordering    
       put('                                                      RANK() OVER (ORDER BY inst_id, child_number) rnk ');
       put('                                                 FROM gv$sql_plan_statistics_all ');
       put('                                                WHERE sql_id = ''''&&sqld360_sqlid.'''' ');
       put('                                                  AND plan_hash_value = '||i.plan_hash_value||') a, ');
       put('                                             skp_steps b ');
       put('                                       WHERE a.rnk = 1');
       put('                                         AND a.id = b.stepid(+) ');
       put('                                         AND (b.skp = 0 OR b.skp IS NULL) ');
       put('                                       ORDER BY a.id)) ');
       put('                SELECT dep, adapt_id, id, '); 
       put('                       (SELECT MAX(adapt_id) ');
       put('                          FROM plan_all b ');
       put('                         WHERE a.dep-1 = b.dep'); 
       put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
       put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
       put('                  FROM plan_all a)');
       put('        UNION ');
       put('        SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name, access_predicates, filter_predicates ');  
       put('          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),''''/row/@op'''') stepid, extractvalue(value(b),''''/row/@skp'''') skp,');
       put('                                          extractvalue(value(b),''''/row/@dep'''') dep');
       put('                                     FROM dba_hist_sql_plan a, ');
       put('                                          TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(a.other_xml),''''/*/display_map/row''''))) b');  
       put('                                    WHERE sql_id = ''''&&sqld360_sqlid.''''');
       put('                                      AND other_xml IS NOT NULL ');
       put('                                      AND plan_hash_value = '||i.plan_hash_value||'),'); 
       put('                 plan_all AS (SELECT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep,'); 
       put('                                     (ROW_NUMBER() OVER (ORDER BY a.id))-1 adapt_id, a.operation, a.options, a.object_name, REPLACE(a.access_predicates, CHR(39) , CHR(92)||CHR(39)) access_predicates, REPLACE(a.filter_predicates, CHR(39) , CHR(92)||CHR(39)) filter_predicates, b.skp');
       put('                                FROM dba_hist_sql_plan a, skp_steps b ');
       put('                               WHERE a.sql_id = ''''&&sqld360_sqlid.''''');
       put('                                 AND a.plan_hash_value = '||i.plan_hash_value||'');
       put('                                 AND a.id = b.stepid(+) ');
       put('                                 AND (b.skp = 0 OR b.skp IS NULL) ');
       put('                               ORDER BY a.id) ');
       put('                SELECT dep, adapt_id, id, '); 
       put('                       (SELECT MAX(adapt_id) ');
       put('                          FROM plan_all b ');
       put('                         WHERE a.dep-1 = b.dep'); 
       put('                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,'); 
       put('                       a.operation operation, a.options, a.object_name, a.access_predicates, a.filter_predicates');
       put('                  FROM plan_all a');
       put('                 WHERE NOT EXISTS (SELECT 1 ');
       put('                             FROM gv$sql_plan_statistics_all ');
       put('                            WHERE plan_hash_value =  '||i.plan_hash_value||'');
       put('                              AND sql_id = ''''&&sqld360_sqlid.'''')');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y'''')) plandata,');
       put('       ashdata');
       put(' WHERE ashdata.id(+) = plandata.id');
       put(' ORDER BY plandata.id');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put('DEF title=''Plan Step IDs timeline for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_uch=''''');
       put('DEF abstract = ''Top SQL Plan Steps''');
       put('DEF vaxis = ''SQL Plan Step ID''');
       put('DEF foot = ''Data is not aggregated, extracted directly from V$ASH, Y-axis report plan steps, size of the bubble is number of samples, color is major contributor (>50%) for bubble''');

       put('COL bubblesDetails NEW_V bubblesDetails');
       put('SELECT ''<br>Step Details<br>''||LISTAGG(step_details,''<br>'') WITHIN GROUP (ORDER BY id) bubblesDetails');
       put('          FROM (SELECT DISTINCT NVL(id,0) id, NVL(id,0)||'' - ''||operation||'' ''||options||'' (obj#:''||object_instance||'')'' step_details');
       put('                  FROM plan_table a');
       put('                 WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND a.timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('                   AND remarks = ''&&sqld360_sqlid.''');
       put('               );');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       null,');
       put('       plan_line_id,');
       put('       CASE WHEN rtr_category > .5 THEN category ELSE ''''Multiple'''' END,');
       put('       num_samples');
       put('  FROM (SELECT end_time, plan_line_id, category, num_samples, rtr_category, ROW_NUMBER() OVER (PARTITION BY end_time, plan_line_id ORDER BY rtr_category DESC) rn_category');
       put('          FROM (SELECT end_time, plan_line_id, category, SUM(num_samples) OVER (PARTITION BY end_time, plan_line_id) num_samples, RATIO_TO_REPORT(num_samples) OVER (PARTITION BY end_time, plan_line_id) rtr_category');
       put('                  FROM (SELECT timestamp end_time, NVL(id,0) plan_line_id, ');
       put('                               CASE WHEN other_tag IS NULL THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END category,'); 
       put('                               COUNT(*) num_samples'); 
       put('                          FROM plan_table');
       put('                         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('                           AND cost =  '||i.plan_hash_value||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('                           --AND partition_id IS NOT NULL');
       put('                           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                         GROUP BY timestamp, NVL(id,0), CASE WHEN other_tag IS NULL THEN ''''CPU'''' WHEN other_tag LIKE ''''%I/O'''' THEN ''''I/O'''' WHEN other_tag = ''''Concurrency'''' THEN ''''Concurrency'''' WHEN other_tag = ''''Cluster'''' THEN ''''Cluster'''' ELSE ''''Other'''' END)');
       put('                 )');
       put('        )');
       put(' WHERE rn_category = 1');
       put(' ORDER BY end_time'); 
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');

       put('DEF title=''Top 15 Step/Event for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.step||'''' ''''||CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
       put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
       put('       END||'''' / ''''||data.event  step_event,');
       put('       data.num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       --put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node step_event,');
       put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options step, object_instance obj#, object_node event,'); 
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       --put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node'); 
       put('         GROUP BY id||'''' - ''''||operation||'''' ''''||options, object_instance, object_node'); 
       put('         ORDER BY 4 DESC) data');
       put(' WHERE rownum <= 15');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');        

       put('----------------------------');

       put('DEF title=''Top 15 Wait events timeline SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''AreaChart''');
       put('DEF stacked = ''isStacked: true,''');
       put('DEF abstract = ''AS (stacked) per top 15 wait events''');
       put('DEF vaxis = ''Active Sessions - AS (stacked)''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH, Y-axis report Active Sessions at any time, not Average Active Sessions''');

       put('COL evt_01 NEW_V evt_01'); 
       put('COL evt_02 NEW_V evt_02'); 
       put('COL evt_03 NEW_V evt_03'); 
       put('COL evt_04 NEW_V evt_04'); 
       put('COL evt_05 NEW_V evt_05'); 
       put('COL evt_06 NEW_V evt_06'); 
       put('COL evt_07 NEW_V evt_07'); 
       put('COL evt_08 NEW_V evt_08'); 
       put('COL evt_09 NEW_V evt_09'); 
       put('COL evt_10 NEW_V evt_10'); 
       put('COL evt_11 NEW_V evt_11'); 
       put('COL evt_12 NEW_V evt_12'); 
       put('COL evt_13 NEW_V evt_13'); 
       put('COL evt_14 NEW_V evt_14'); 
       put('COL evt_15 NEW_V evt_15');
       put('COL tit_01 NEW_V tit_01'); 
       put('COL tit_02 NEW_V tit_02'); 
       put('COL tit_03 NEW_V tit_03'); 
       put('COL tit_04 NEW_V tit_04'); 
       put('COL tit_05 NEW_V tit_05'); 
       put('COL tit_06 NEW_V tit_06'); 
       put('COL tit_07 NEW_V tit_07'); 
       put('COL tit_08 NEW_V tit_08'); 
       put('COL tit_09 NEW_V tit_09'); 
       put('COL tit_10 NEW_V tit_10'); 
       put('COL tit_11 NEW_V tit_11'); 
       put('COL tit_12 NEW_V tit_12'); 
       put('COL tit_13 NEW_V tit_13'); 
       put('COL tit_14 NEW_V tit_14'); 
       put('COL tit_15 NEW_V tit_15'); 

       put('SELECT MAX(CASE WHEN ranking = 1  THEN cpu_or_event ELSE '''' END) evt_01,');
       put('       MAX(CASE WHEN ranking = 2  THEN cpu_or_event ELSE '''' END) evt_02,');              
       put('       MAX(CASE WHEN ranking = 3  THEN cpu_or_event ELSE '''' END) evt_03,'); 
       put('       MAX(CASE WHEN ranking = 4  THEN cpu_or_event ELSE '''' END) evt_04,'); 
       put('       MAX(CASE WHEN ranking = 5  THEN cpu_or_event ELSE '''' END) evt_05,'); 
       put('       MAX(CASE WHEN ranking = 6  THEN cpu_or_event ELSE '''' END) evt_06,'); 
       put('       MAX(CASE WHEN ranking = 7  THEN cpu_or_event ELSE '''' END) evt_07,'); 
       put('       MAX(CASE WHEN ranking = 8  THEN cpu_or_event ELSE '''' END) evt_08,'); 
       put('       MAX(CASE WHEN ranking = 9  THEN cpu_or_event ELSE '''' END) evt_09,'); 
       put('       MAX(CASE WHEN ranking = 10 THEN cpu_or_event ELSE '''' END) evt_10,');
       put('       MAX(CASE WHEN ranking = 11 THEN cpu_or_event ELSE '''' END) evt_11,');
       put('       MAX(CASE WHEN ranking = 12 THEN cpu_or_event ELSE '''' END) evt_12,');
       put('       MAX(CASE WHEN ranking = 13 THEN cpu_or_event ELSE '''' END) evt_13,');
       put('       MAX(CASE WHEN ranking = 14 THEN cpu_or_event ELSE '''' END) evt_14,');
       put('       MAX(CASE WHEN ranking = 15 THEN cpu_or_event ELSE '''' END) evt_15 ');
       put('  FROM (SELECT 1 fake, object_node cpu_or_event,');
       put('               ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) ranking');
       put('          FROM plan_table'); 
       put('         WHERE statement_id = ''SQLD360_ASH_DATA_HIST''');
       put('           AND cost = '||i.plan_hash_value);
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,3)+1,INSTR(partition_stop,'','',1,4)-INSTR(partition_stop,'','',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,4)+1,INSTR(partition_stop,'','',1,5)-INSTR(partition_stop,'','',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'','',1,5)+1,INSTR(partition_stop,'','',1,6)-INSTR(partition_stop,'','',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''||j.min_sample_time||''', ''YYYYMMDDHH24MISS'') AND TO_DATE('''||j.max_sample_time||''', ''YYYYMMDDHH24MISS'') ');
       put('           AND remarks = ''&&sqld360_sqlid.''');
       put('         GROUP BY object_node) ash,');
       put('       (SELECT 1 fake FROM dual) b'); -- this is in case there is no row in ASH
       put(' WHERE ash.fake(+) = b.fake');
       put('   AND ranking <= 15');
       put('/');    

       put('SET DEF @');

       put('SELECT SUBSTR(''@evt_01.'',1,27) tit_01,'); 
       put('       SUBSTR(''@evt_02.'',1,27) tit_02,');
       put('       SUBSTR(''@evt_03.'',1,27) tit_03,');
       put('       SUBSTR(''@evt_04.'',1,27) tit_04,');
       put('       SUBSTR(''@evt_05.'',1,27) tit_05,');
       put('       SUBSTR(''@evt_06.'',1,27) tit_06,');
       put('       SUBSTR(''@evt_07.'',1,27) tit_07,');
       put('       SUBSTR(''@evt_08.'',1,27) tit_08,');
       put('       SUBSTR(''@evt_09.'',1,27) tit_09,');
       put('       SUBSTR(''@evt_10.'',1,27) tit_10,'); 
       put('       SUBSTR(''@evt_11.'',1,27) tit_11,');
       put('       SUBSTR(''@evt_12.'',1,27) tit_12,');
       put('       SUBSTR(''@evt_13.'',1,27) tit_13,');
       put('       SUBSTR(''@evt_14.'',1,27) tit_14,');
       put('       SUBSTR(''@evt_15.'',1,27) tit_15');
       put('  FROM DUAL');
       put('/');

       put('COL e01 NOPRI');
       put('COL e02 NOPRI');
       put('COL e03 NOPRI');
       put('COL e04 NOPRI');
       put('COL e05 NOPRI');
       put('COL e06 NOPRI');
       put('COL e07 NOPRI');
       put('COL e08 NOPRI');
       put('COL e09 NOPRI');
       put('COL e10 NOPRI');
       put('COL e11 NOPRI');
       put('COL e12 NOPRI');
       put('COL e13 NOPRI');
       put('COL e14 NOPRI');
       put('COL e15 NOPRI');

       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(sample_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       NVL(num_sess_01,0) "e01@tit_01." ,');
       put('       NVL(num_sess_02,0) "e02@tit_02." ,');
       put('       NVL(num_sess_03,0) "e03@tit_03." ,');
       put('       NVL(num_sess_04,0) "e04@tit_04." ,');
       put('       NVL(num_sess_05,0) "e05@tit_05." ,');
       put('       NVL(num_sess_06,0) "e06@tit_06." ,');
       put('       NVL(num_sess_07,0) "e07@tit_07." ,');
       put('       NVL(num_sess_08,0) "e08@tit_08." ,');
       put('       NVL(num_sess_09,0) "e09@tit_09." ,');
       put('       NVL(num_sess_10,0) "e10@tit_10." ,');
       put('       NVL(num_sess_11,0) "e11@tit_11." ,');
       put('       NVL(num_sess_12,0) "e12@tit_12." ,');
       put('       NVL(num_sess_13,0) "e13@tit_13." ,');
       put('       NVL(num_sess_14,0) "e14@tit_14." ,');
       put('       NVL(num_sess_15,0) "e15@tit_15." ');
       put('  FROM (SELECT sample_time,');
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_01.'''' THEN num_sess ELSE NULL END) num_sess_01,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_02.'''' THEN num_sess ELSE NULL END) num_sess_02,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_03.'''' THEN num_sess ELSE NULL END) num_sess_03,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_04.'''' THEN num_sess ELSE NULL END) num_sess_04,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_05.'''' THEN num_sess ELSE NULL END) num_sess_05,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_06.'''' THEN num_sess ELSE NULL END) num_sess_06,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_07.'''' THEN num_sess ELSE NULL END) num_sess_07,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_08.'''' THEN num_sess ELSE NULL END) num_sess_08,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_09.'''' THEN num_sess ELSE NULL END) num_sess_09,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_10.'''' THEN num_sess ELSE NULL END) num_sess_10,'); 
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_11.'''' THEN num_sess ELSE NULL END) num_sess_11,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_12.'''' THEN num_sess ELSE NULL END) num_sess_12,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_13.'''' THEN num_sess ELSE NULL END) num_sess_13,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_14.'''' THEN num_sess ELSE NULL END) num_sess_14,');  
       put('               MAX(CASE WHEN cpu_or_event  = ''''@evt_15.'''' THEN num_sess ELSE NULL END) num_sess_15'); 
       put('          FROM (SELECT timestamp sample_time,');
       put('                       object_node cpu_or_event,'); 
       put('                       count(*) num_sess');
       put('                  FROM plan_table');
       put('                 WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('                   AND remarks = ''''&&sqld360_sqlid.''''');
       put('                   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('                   AND cost = '||i.plan_hash_value);
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('                   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('                   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('                   AND object_node IN (''''@evt_01.'''',''''@evt_02.'''',''''@evt_03.'''',''''@evt_04.'''',''''@evt_05.'''',''''@evt_06.'''',');
       put('                                       ''''@evt_07.'''',''''@evt_08.'''',''''@evt_09.'''',''''@evt_10.'''',''''@evt_11.'''',''''@evt_12.'''',');
       put('                                       ''''@evt_13.'''',''''@evt_14.'''',''''@evt_15.'''')');
       put('                 GROUP BY timestamp, object_node)');
       put('         GROUP BY sample_time)');
       put(' ORDER BY 3 ');
       put(''';');
       put('END;');
       put('/ ');

       put('SET DEF &');
       put('@sql/sqld360_9a_pre_one.sql');

       put('COL evt01_ PRI');
       put('COL evt02_ PRI');
       put('COL evt03_ PRI');
       put('COL evt04_ PRI');
       put('COL evt05_ PRI');
       put('COL evt06_ PRI');
       put('COL evt07_ PRI');
       put('COL evt08_ PRI');
       put('COL evt09_ PRI');
       put('COL evt10_ PRI');
       put('COL evt11_ PRI');
       put('COL evt12_ PRI');
       put('COL evt13_ PRI');
       put('COL evt14_ PRI');
       put('COL evt15_ PRI');     

       put('UNDEF evt_01'); 
       put('UNDEF evt_02'); 
       put('UNDEF evt_03'); 
       put('UNDEF evt_04'); 
       put('UNDEF evt_05'); 
       put('UNDEF evt_06'); 
       put('UNDEF evt_07'); 
       put('UNDEF evt_08'); 
       put('UNDEF evt_09'); 
       put('UNDEF evt_10'); 
       put('UNDEF evt_11'); 
       put('UNDEF evt_12'); 
       put('UNDEF evt_13'); 
       put('UNDEF evt_14'); 
       put('UNDEF evt_15'); 

       put('----------------------------');       

       put('DEF title=''DB Time by top 64 process for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''64''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.qcpx_process,');
       put('       data.num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(data.num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       --put('  FROM (SELECT id||'''' - ''''||operation||'''' ''''||options||'''' / ''''||object_node step_event,');
       put('  FROM (SELECT NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost  qcpx_process, ');   
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY NVL2(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)), ''''PX Proc - '''', ''''QC - '''')||position||''''.''''||cpu_cost||''''.''''||io_cost   ');  
       put('         ORDER BY 2 DESC) data');
       put(' WHERE rownum <= 64');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql'); 

       put('----------------------------');

       put('DEF title=''PGA and TEMP usage for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Bytes''');
       put('DEF tit_01 = ''PGA Usage''');
       put('DEF tit_02 = ''TEMP Usage''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       pga_allocated,');
       put('       temp_space_allocated,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1))) pga_allocated,'); 
       put('               SUM(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1))) temp_space_allocated'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');   

       put('----------------------------');           

       put('DEF title=''Read and Write I/O requests for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''Number of I/O requests''');
       put('DEF tit_01 = ''Read I/O Request''');
       put('DEF tit_02 = ''Write I/O Request''');
       put('DEF tit_03 = ''''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_requests,');
       put('       write_io_requests,');
       put('       0 dummy_03,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_requests,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_requests'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');  

       put('----------------------------');       

       put('DEF title=''Read, Write and Interconnect I/O bytes for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('DEF skip_lch=''''');
       put('DEF chartype = ''LineChart''');
       put('DEF stacked = ''''');
       put('DEF vaxis = ''I/O bytes''');
       put('DEF tit_01 = ''Read I/O Bytes''');
       put('DEF tit_02 = ''Write I/O Bytes''');
       put('DEF tit_03 = ''Interconnect I/O Bytes''');
       put('DEF tit_04 = ''''');
       put('DEF tit_05 = ''''');
       put('DEF tit_06 = ''''');
       put('DEF tit_07 = ''''');
       put('DEF tit_08 = ''''');
       put('DEF tit_09 = ''''');
       put('DEF tit_10 = ''''');
       put('DEF tit_11 = ''''');
       put('DEF tit_12 = ''''');
       put('DEF tit_13 = ''''');
       put('DEF tit_14 = ''''');
       put('DEF tit_15 = ''''');
       put('DEF foot = ''Data is not aggregated, extracted directly from DBA_HIST_ASH''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT 0 snap_id,');
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') begin_time,'); 
       put('       TO_CHAR(end_time, ''''YYYY-MM-DD HH24:MI:SS'''') end_time,');
       put('       read_io_bytes,');
       put('       write_io_bytes,');
       put('       interconnect_io_bytes,');
       put('       0 dummy_04,');
       put('       0 dummy_05,');
       put('       0 dummy_06,');
       put('       0 dummy_07,');
       put('       0 dummy_08,');
       put('       0 dummy_09,');
       put('       0 dummy_10,');
       put('       0 dummy_11,');
       put('       0 dummy_12,');
       put('       0 dummy_13,');
       put('       0 dummy_14,');
       put('       0 dummy_15');
       put('  FROM (SELECT timestamp end_time,');
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) read_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) write_io_bytes,'); 
       put('               SUM(NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)),0)/ ');
       put('                   ROUND(GREATEST(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1))/1e6,1))) interconnect_io_bytes'); 
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''SQLD360_ASH_DATA_HIST''''');
       put('           AND cost =  '||i.plan_hash_value||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('           AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('           AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('           AND remarks = ''''&&sqld360_sqlid.'''''); 
       put('           AND partition_id IS NOT NULL');
       put('           AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put('         GROUP BY timestamp)');
       put(' ORDER BY 3');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');      

       put('DEF title = ''Raw Data for SQL_EXEC_ID '||j.sql_exec_id||' of PHV '||i.plan_hash_value||'''');
       put('DEF main_table = ''DBA_HIST_ACTIVE_SESS_HISTORY''');
       put('BEGIN ');
       put('  :sql_text := ''');
       put('SELECT /*+ &&top_level_hints. */ ');
       put('       statement_id     source,  ');
       put('       search_columns   dbid,    ');
       put('       cardinality      snap_id, ');
       put('       position         instance_number,  ');
       put('       parent_id        sample_id,        ');
       put('       TO_CHAR(timestamp, ''''YYYY-MM-DD/HH24:MI:SS'''')        sample_time, ');
       put('       partition_id     sql_exec_id, ');
       put('       TO_CHAR(TO_DATE(distribution,''''YYYYMMDDHH24MISS''''), ''''YYYY-MM-DD/HH24:MI:SS'''')  sql_exec_start, ');
       put('       cpu_cost         session_id,        ');
       put('       io_cost          session_serial#,   ');
       put('       bytes            user_id,           ');
       put('       remarks          sql_id,            ');
       put('       cost             plan_hash_value,   ');
       put('       id               sql_plan_line_id,  ');
       put('       operation        sql_plan_operation,');  
       put('       options          sql_plan_options,  '); 
       put('       object_node      cpu_or_event,      ');
       put('       other_tag        wait_class,        ');
       put('       TO_NUMBER(SUBSTR(partition_start,1,INSTR(partition_start,'''','''',1,1)-1)) seq#, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,1)+1,INSTR(partition_start,'''','''',1,2)-INSTR(partition_start,'''','''',1,1)-1) p1text, ');  
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,2)+1,INSTR(partition_start,'''','''',1,3)-INSTR(partition_start,'''','''',1,2)-1)) p1, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,3)+1,INSTR(partition_start,'''','''',1,4)-INSTR(partition_start,'''','''',1,3)-1) p2text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,4)+1,INSTR(partition_start,'''','''',1,5)-INSTR(partition_start,'''','''',1,4)-1)) p2, ');
       put('       SUBSTR(partition_start,INSTR(partition_start,'''','''',1,5)+1,INSTR(partition_start,'''','''',1,6)-INSTR(partition_start,'''','''',1,5)-1) p3text,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,6)+1,INSTR(partition_start,'''','''',1,7)-INSTR(partition_start,'''','''',1,6)-1)) p3, ');
       put('       object_instance  current_obj#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,7)+1,INSTR(partition_start,'''','''',1,8)-INSTR(partition_start,'''','''',1,7)-1)) current_file#,  ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,8)+1,INSTR(partition_start,'''','''',1,9)-INSTR(partition_start,'''','''',1,8)-1)) current_block#, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,9)+1,INSTR(partition_start,'''','''',1,10)-INSTR(partition_start,'''','''',1,9)-1)) current_row#,  ');
       put('       SUBSTR(partition_stop,1,INSTR(partition_stop,'''','''',1,1)-1) in_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,1)+1,INSTR(partition_stop,'''','''',1,2)-INSTR(partition_stop,'''','''',1,1)-1) in_hard_parse, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,2)+1,INSTR(partition_stop,'''','''',1,3)-INSTR(partition_stop,'''','''',1,2)-1) in_sql_execution, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)) qc_instance_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)) qc_session_id,  ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)) qc_session_serial#, ');
       put('       SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,6)+1,INSTR(partition_stop,'''','''',1,7)-INSTR(partition_stop,'''','''',1,6)-1) blocking_session_status, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,7)+1,INSTR(partition_stop,'''','''',1,8)-INSTR(partition_stop,'''','''',1,7)-1)) blocking_session, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,8)+1,INSTR(partition_stop,'''','''',1,9)-INSTR(partition_stop,'''','''',1,8)-1)) blocking_session_serial#, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,9)+1,INSTR(partition_stop,'''','''',1,10)-INSTR(partition_stop,'''','''',1,9)-1)) blocking_inst_id, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,10)+1,INSTR(partition_stop,'''','''',1,11)-INSTR(partition_stop,'''','''',1,10)-1)) px_flags, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,11)+1,INSTR(partition_stop,'''','''',1,12)-INSTR(partition_stop,'''','''',1,11)-1)) pga_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,12)+1,INSTR(partition_stop,'''','''',1,13)-INSTR(partition_stop,'''','''',1,12)-1)) temp_space_allocated, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,10)+1,INSTR(partition_start,'''','''',1,11)-INSTR(partition_start,'''','''',1,10)-1)) tm_delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,11)+1,INSTR(partition_start,'''','''',1,12)-INSTR(partition_start,'''','''',1,11)-1)) tm_delta_cpu_time, ');
       put('       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,'''','''',1,12)+1)) tm_delta_db_time, '); 
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,13)+1,INSTR(partition_stop,'''','''',1,14)-INSTR(partition_stop,'''','''',1,13)-1)) delta_time, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,14)+1,INSTR(partition_stop,'''','''',1,15)-INSTR(partition_stop,'''','''',1,14)-1)) delta_read_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,15)+1,INSTR(partition_stop,'''','''',1,16)-INSTR(partition_stop,'''','''',1,15)-1)) delta_write_io_requests, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,16)+1,INSTR(partition_stop,'''','''',1,17)-INSTR(partition_stop,'''','''',1,16)-1)) delta_read_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,17)+1,INSTR(partition_stop,'''','''',1,18)-INSTR(partition_stop,'''','''',1,17)-1)) delta_write_io_bytes, ');
       put('       TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,18)+1)) delta_interconnect_io_bytes ');
       put('  FROM plan_table '); 
       put(' WHERE remarks = ''''&&sqld360_sqlid.'''' ');
       put('   AND statement_id = ''''SQLD360_ASH_DATA_HIST'''' ');
       put('   AND cost =  '||i.plan_hash_value||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,3)+1,INSTR(partition_stop,'''','''',1,4)-INSTR(partition_stop,'''','''',1,3)-1)),position) = '||j.inst_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,4)+1,INSTR(partition_stop,'''','''',1,5)-INSTR(partition_stop,'''','''',1,4)-1)),cpu_cost) = '||j.session_id||'');
       put('   AND NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,'''','''',1,5)+1,INSTR(partition_stop,'''','''',1,6)-INSTR(partition_stop,'''','''',1,5)-1)),io_cost) = '||j.session_serial#||'');
       put('   AND timestamp BETWEEN TO_DATE('''''||j.min_sample_time||''''', ''''YYYYMMDDHH24MISS'''') AND TO_DATE('''''||j.max_sample_time||''''', ''''YYYYMMDDHH24MISS'''') ');
       put('   AND ''''&&diagnostics_pack.'''' = ''''Y''''');
       put(' ORDER BY timestamp,position ');
       put(''';');
       put('END;');
       put('/');
       put('@sql/sqld360_9a_pre_one.sql');

       put('----------------------------');       

       put('SPO &&one_spool_filename..html APP;');
       put('PRO <br>');
       put('SPO OFF');
      
    END LOOP;

    -- end of v1601
    put('PRO </ol>');
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO </td>');
  END LOOP;
END;
/
SPO &&sqld360_main_report..html APP;
@sqld360_plans_analysis_&&sqld360_sqlid._driver.sql

SPO &&sqld360_main_report..html APP;
PRO </tr></table>
@@sqld360_0e_html_footer.sql
SPO OFF
SET PAGES 50000

HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_plans_analysis_&&sqld360_sqlid._driver.sql

DEF sqld360_main_report = &&sqld360_main_report_bck.