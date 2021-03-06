/*
Test Case: insert & update
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
changes committed after the query started are never seen
  A begin insert
                   B begin update which satisfy A
                   B commit
  A update end
  A commit

NUM_CLIENTS = 2
prepare (5,6,7)
C1: set @newincr=0;
C1: insert into t select (@newincr:=@newincr+1),(@newincr)||'b' from (select sleep(1)) x, t limit 3;
C2: update t set id=id+1,col=col||'c' where 0 = (select sleep(1)) and id>0;
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10) unique);
C1: create index idx on t(id);
C1: insert into t values(5,'a');
C1: insert into t values(6,'b');
C1: insert into t values(7,'c');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: set @newincr=0;
C1: insert into t select (@newincr:=@newincr+1),(@newincr)||'b' from (select sleep(1)) x, t limit 3; 
C2: update t set id=id+1,col=col||'c' where 0 = (select sleep(1)) and id>0;
MC: wait until C1 ready;
MC: wait until C2 ready;
C1: commit;          
MC: wait until C1 ready;

C2: commit;          
/* result should be (1,1b)(2,2b)(3,3b)(6,ac)(7,bc)(8,cc) */
C2: select * from t order by 1,2; 
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;

