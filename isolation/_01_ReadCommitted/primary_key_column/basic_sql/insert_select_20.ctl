/*
Test Case: insert & select
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
changes committed after the query started are never seen
do not use index

NUM_CLIENTS = 2
prepare(1,3,7)
C1: select * from t where sleep(1) =0 order by col; --expected only can see 1,3,7
C2: insert into t values(2,'abc'); 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int primary key,col varchar(10));
C1: insert into t values(1,'aa');
C1: insert into t values(3,'bb');
C1: insert into t values(7,'cc');
C1: commit;

MC: wait until C1 ready;

/* test case */
C1: select t.* from t, (select sleep(3)) x order by col;
MC: sleep 2;
MC: wait until C1 ready;
C2: insert into t values(2,'abc');
MC: wait until C2 ready;
C2: commit work;
C1: select * from t order by col;
C1: commit;

C2: quit;
C1: quit;

