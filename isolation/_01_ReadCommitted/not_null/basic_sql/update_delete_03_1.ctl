/*
Test Case: update & delete
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/not_null/basic_sql/update_delete_03.ctl
Author: Ray

Test Plan: 
Test concurrent UPDATE/DELETE transactions in MVCC (with NOT NULL constraint)

Test Scenario:
C1 update, C2 delete, the affected rows are not overlapped (based on where clause) 
C1 update does affect C2 delete
C1 completed before C2 finished execution since C2 takes a long time
C1 where clause is on index (i.e. index scan), C2 where clause is not on index (i.e. heap scan)
C1 commit, C2 commit
Metrics: schema = single table, index = single index(PK), data size = small, where clause = simple

Test Point:
1) C1 and C2 will not be waiting (Locking Test)
2) C1 instances should be updated
   C2 instances should be deleted based on its original snapshot (Visibility Test)

NUM_CLIENTS = 3
C1: update table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT NOT NULL PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2));
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET col = 'abc' WHERE id BETWEEN 4 AND 5;
C2: DELETE FROM t1 WHERE col = 'abc' and 0 = (select sleep(4));
/* expect: no transactions need to wait */
MC: wait until C1 ready;
/* expect: C1 select - id = 4,5 are updated */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
MC: wait until C1 ready; 
/* expect: C2 finished execution after C1 commit, 2 rows (id=1,7)deleted message, C2 select - id = 1,7(C2) are deleted, id = 4,5(C1) are updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready; 
/* expect: the instances of id = 4,5 are updated, id = 1,7 are deleted */
C3: select * from t1 order by 1,2;
C3: commit;

C1: quit;
C2: quit;
C3: quit;
