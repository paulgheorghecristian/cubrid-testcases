/*
Test Case: delete & delete
Priority: 1
Reference case: 
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are overlapped (with pk schema)

Test Scenario:
C1 delete, C2 delete, the affected rows are overlapped
C1 delete instances include(this case - equals) the instances from C2 delete 
C1, C2 where clause are on pk (index scan)
C1 commit, C2 commit
Metrics: schema = with pk, data size = small, where clause = simple, DELETE state = single table

Test Point:
1) C2 needs to wait C1 completed
2) The data affected from C1 will be deleted, the C2 instances won't be deleted again
   (i.e.the version will be updated but the C2 search condition is not satisfied anymore) 

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
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
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10));
C1: INSERT INTO t1 VALUES(1,'abc');INSERT INTO t1 VALUES(2,'def');INSERT INTO t1 VALUES(3,'ghi');INSERT INTO t1 VALUES(4,'jkl');INSERT INTO t1 VALUES(5,'mno');INSERT INTO t1 VALUES(6,'pqr');INSERT INTO t1 VALUES(7,'abc');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id = 2;
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE id > 1 and id < 3;
/* expect: C2 needs to wait until C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 2 is deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 0 row deleted message should generated once C2 ready, C2 select - id = 2 is deleted */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: the instance of id = 2 is deleted */
C3: select * from t1 order by 1,2;

C3: commit;
C1: quit;
C2: quit;
C3: quit;

