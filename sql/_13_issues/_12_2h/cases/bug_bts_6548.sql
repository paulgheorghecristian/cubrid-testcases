--+ holdcas on;
set system parameters 'dont_reuse_heap_file=yes';

create table t (i int, j int);

insert into t values (1, 2);
insert into t values (2, 4);
insert into t values (3, 10);
insert into t values (4, 3);

select * from t;

select * from t connect by prior j = i;

select * from t start with i = 1 connect by prior j = i;

select * from t connect by prior j = i start with i = 1;
set system parameters 'dont_reuse_heap_file=no';
drop table t;
commit;
--+ holdcas off;
