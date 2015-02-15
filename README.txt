SQLd360 v1501 (2015-02-15) by Mauro Pagano

SQLd360 is a "free to use" tool to perform an in-depth investigation of a SQL statement. 
It collects detailed information around the SQL. It also helps to document any findings.
SQLd360 installs nothing. For better results execute connected as SYS or DBA.
It takes a few minutes to execute. Output ZIP file can be large (several MBs), so
you may want to execute SQLd360 from a system directory with at least 1 GB of free 
space. 

Steps
~~~~~
1. Unzip SQLd360.zip, navigate to the root sqld360 directory, and connect as SYS, 
   DBA, or any User with Data Dictionary access:

   $ unzip sqld360.zip
   $ cd sqld360
   $ sqlplus / as sysdba

2. Execute sqld360.sql indicating three input parameters. The first one is to specify 
   the SQL ID for the SQL you want to analyze. The second one is to specify if your 
   database is licensed for the Oracle Tuning Pack, the Diagnostics Pack or None 
   [ T | D | N ]. The third parameter indicates up to how many days of history you
   want sqld360 to query. Example below specifies SQL ID 0vy6pt4krb3gm, Tuning Pack 
   and 31 days of history. Actual days of history used depends on retention period. 
   Value used is raised up to 31 days if history permits.

   SQL> @sqld360.sql 0vy6pt4krb3gm T 31
   
3. Unzip output sqld360_<dbname>_<sqlid>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 0001_sqld360_<dbname>_index.html

****************************************************************************************
   
    SQLD360 - Enkitec's Oracle SQL 360-degree View
    Copyright (C) 2015  Mauro Pagano

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
