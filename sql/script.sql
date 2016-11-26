/*
 * PLNFND script example
 * Name of the script must be script.sql
 */

/*
 * Add here the ALTER SESSIONS
 */

/*
 * Add here the SQL text, remember the mandatory
 * comment  ^^pathfinder_testid 
 *
select /* ^^pathfinder_testid / t1.n1, t1.n2, t2.n1, t2.n2
  from t1, t2
 where t1.n1 = 0
   and t1.n2 = 1000
   and t2.id = t1.id
   and t2.n1 = 0
   and t2.n2 = 400;
   */

with a as (select 1 n1, 1 n2 from dual union all 
           select 2 n1, 3 n2 from dual union all
           select 3 n1, 3 n2 from dual )
select /* ^^pathfinder_testid */* from (
  select *
  from a
 where n1 = 1
union all
select *
  from a
 where n1 = 2)
where n2 = 3;