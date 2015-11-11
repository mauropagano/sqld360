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
 */
select /* ^^pathfinder_testid */ t1.n1, t1.n2, t2.n1, t2.n2
  from t1, t2
 where t1.n1 = 0
   and t1.n2 = 1000
   and t2.id = t1.id
   and t2.n1 = 0
   and t2.n2 = 400;
