/*
Test Case: update & delete
Priority: 1
Reference case:
Author: Rong Xu

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance) 

Test Point:
C1 update to another partition, C2 delete the old row using index

NUM_CLIENTS = 2
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS t;
C1: create table t(id int,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: create index idx on t(id);
C1: commit work;
MC: wait until C1 ready;

C1: INSERT INTO t VALUES(1,'abc'),(20,'def'),(3,'ghi'),(40,'jkl');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C2: select * from t order by 1,2;
MC: wait until C2 ready;

C1: UPDATE t SET id=20 where id=1;
MC: wait until C1 ready;

/* ERROR: Serializable conflict due to concurent update */
C2: DELETE FROM t where id=1;
MC: wait until C2 blocked;

C1: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;

/* expect (1,'abc'),(20,'def'),(3,'ghi'),(40,'jkl') */
C2: select * from t order by 1,2;
C2: commit;
MC: wait until C2 ready;

C1: quit;
C2: quit;
