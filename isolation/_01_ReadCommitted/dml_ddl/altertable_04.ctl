/*
Test Case: alter table & delete,insert,select,update
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/dml_ddl/altertable_03.ctl
Author: Lily

Test Point:
C1 alter table, other tansactions are blocked.

NUM_CLIENTS = 3
C1: ALTER TABLE tb1 ADD COLUMN email VARCHAR(20);  --rollback
C2: INSERT INTO tb1 VALUES(5,'Test',4'test@nnn.com'); 
C3: DELETE FROM tb1 WHERE col='efg'; 
*/

MC: setup NUM_CLIENTS = 3;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;
C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;
/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1(id INT PRIMARY KEY,col VARCHAR(10), grade INT);
C1: INSERT INTO tb1 VALUES(1,'abc',10);
C1: INSERT INTO tb1 VALUES(2,'efg',11);
C1: INSERT INTO tb1 VALUES(3,'hijk',12);
C1: commit work;

/* test case */
C1: ALTER TABLE tb1 ADD COLUMN email VARCHAR(20);
MC: wait until C1 ready;
C2: INSERT INTO tb1 VALUES(5,'Test',4);
MC: sleep 1;
MC: wait until C2 blocked;
C3: DELETE FROM tb1 WHERE col='efg';
MC: sleep 1;
MC: wait until C3 blocked;
C1: rollback;
MC: wait until C1 ready;
MC: wait until C2 ready;
MC: wait until C3 ready;
C2: SELECT * FROM tb1 ORDER BY id;
MC: wait until C2 ready;
C3: SELECT * FROM tb1 ORDER BY id;
C3: quit;
C2: quit;
C1: quit;
