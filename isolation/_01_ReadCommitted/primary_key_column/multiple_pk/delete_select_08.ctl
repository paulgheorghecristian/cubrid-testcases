/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/multiple_pk/delete_select_01.ctl
Author: Lily

Test Point:
Uncommitted data are never seen by other queries.

NUM_CLIENTS = 3
C1: DELETE FROM tb1 ;  --commited
C2: DELETE FROM tb1 ;  --not commited
C3: SELECT * FROM tb1 ORDER BY id;
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
C1: CREATE TABLE tb1(id INT,col VARCHAR(10),PRIMARY KEY (id,col));
C1: INSERT INTO tb1 VALUES(1,'abc'),(1,'efd'),(2,'xyz'),(2,'tea'),(2,'web'),(3,'xyz'),(3,'fun');
C1: commit work;

MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE col='xyz' AND id=3;
MC: wait until C1 ready;

C2: DELETE FROM tb1 WHERE col='fun' AND id=3;
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;

C1: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2; 
MC: wait until C1 ready;

C2: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2;    
MC: wait until C2 ready;

C3: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2;    
MC: wait until C3 ready;

C2: rollback;
MC: wait until C2 ready;

C1: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2;                   
MC: wait until C1 ready;

C2: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2;
MC: wait until C2 ready;

C3: SELECT * FROM tb1 WHERE id >0 ORDER BY id,2;
MC: wait until C3 ready;

C3: quit;
C2: quit;
C1: quit;
