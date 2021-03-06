/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/common_index/aggregate/delete_select_01.ctl 
Author: Lily

Test Point:
Reading queries can only have a look at data committed before the queries began
changes committed after the query started are never seen
there are many unvacuum version, test select avg(id) correctness
combination 
a) some user committed before the query begin 
b) some begin before the select begin, but commit after the select begin 
c) some begin before the select begin, commit after the select end 
d) some begin after the select begin, commit before the select end 
e) some begin after the select begin, commit after the select end

NUM_CLIENTS = 6
*/
MC: setup NUM_CLIENTS = 6;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;
C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;
C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level read committed;
C5: set transaction lock timeout INFINITE;
C5: set transaction isolation level read committed;
C6: set transaction lock timeout INFINITE;
C6: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1(id INT PRIMARY KEY,col VARCHAR(10));
C1: INSERT INTO tb1 SELECT rownum,rownum%10 FROM db_class a,db_class b,db_class c,db_class d where rownum <= 100000;
C1: commit;
MC: sleep 5;
MC: wait until C1 ready;

C1: update tb1 set id=id+100000 where mod(id,5)=0;
C2: update tb1 set id=id+100000 where mod(id,5)=1;
C3: update tb1 set id=id+100000 where mod(id,5)=2;
C4: update tb1 set id=id+100000 where mod(id,5)=3;
C5: update tb1 set id=id+100000 where mod(id,5)=4;
MC: sleep 10;
MC: wait until C4 ready;
C1: commit;
C2: commit;
C3: commit;
C4: commit;
C5: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;
MC: wait until C3 ready;
MC: wait until C4 ready;
MC: wait until C5 ready;

/* test case */
C1: DELETE FROM tb1 WHERE id BETWEEN 100003 AND 100005;
MC: wait until C1 ready;
C5: DELETE FROM tb1 WHERE id BETWEEN 100010 AND 100020;
MC: wait until C5 ready;
C1: commit work;
MC: wait until C1 ready;
C2: DELETE FROM tb1 WHERE id BETWEEN 100300 AND 100310;
MC: wait until C2 ready;

C6: SELECT col,AVG(id),sleep(1) FROM tb1 WHERE id BETWEEN 100001 AND 190000 GROUP BY col ORDER BY col;
C3: DELETE FROM tb1 WHERE id BETWEEN 100100 AND 100150; 
MC: wait until C3 ready;

C2: commit work;
MC: wait until C2 ready;
C3: commit work;
MC: wait until C3 ready;
C4: DELETE FROM tb1 WHERE id BETWEEN 100200 AND 100210;
MC: sleep 10;
C4: commit;
MC: wait until C4 ready;
C5: commit;
MC: wait until C5 ready;
C6: commit;
MC: wait until C6 ready;

C6: quit;
C5: quit;
C4: quit;
C3: quit;
C2: quit;
C1: quit;

