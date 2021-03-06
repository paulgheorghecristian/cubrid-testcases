/*
Test Case: update & delete
Priority: 1
Reference case:
Author: Rong Xu

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance) 

Test Point:
C1 update, C2 delete, the affected rows are not overlapped

NUM_CLIENTS = 2
C1: UPDATE t1 SET col = 'abcd' WHERE id >= 5;
C2: DELETE FROM t1 WHERE id <= 2;  --expected no block
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: create table t1(id int primary key,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: INSERT INTO t1 VALUES(1,'abc');
C1: INSERT INTO t1 VALUES(2,'def');
C1: INSERT INTO t1 VALUES(3,'ghi');
C1: INSERT INTO t1 VALUES(4,'jkl');
C1: INSERT INTO t1 VALUES(5,'mno');
C1: INSERT INTO t1 VALUES(6,'pqr');
C1: INSERT INTO t1 VALUES(7,'abc');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET col = 'abcd' WHERE id >= 5;
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE id <= 2;
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 5,6,7 are updated */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;
/* expect: C2 select - id = 1,2 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 5,6,7 are updated & id = 1,2 are deleted */
C3: select * from t1 order by 1,2;
C3: commit;

C1: quit;
C2: quit;
C3: quit;
