--+ holdcas on;
set  system parameters 'dont_reuse_heap_file=yes';

create table t( i int, a varchar(10))
PARTITION BY RANGE (i)
(PARTITION before_10 VALUES LESS THAN (10),
PARTITION before_20 VALUES LESS THAN (20));

create table s( i int, a varchar(10))
PARTITION BY RANGE (i)
(PARTITION before_10 VALUES LESS THAN (10),
PARTITION before_20 VALUES LESS THAN (20));

create index idx_t on t(lower(a));

create index idx_s on s(lower(a));

insert into t values (1,'t-1');

insert into t values (9,'t-9');

insert into t values (11,'t-11');

insert into t values (19,'t-19');

insert into s values (1,'t-1');

insert into s values (9,'t-9');

insert into s values (11,'t-11');

insert into s values (19,'t-19');

--Test
select /*+ recompile ordered */ * from t,s where t.i=s.i  order by t.i;

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where lower(t.a)=lower(s.a) and lower(t.a)>'t-1'  order by lower(t.a);

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where lower(t.a)=lower(s.a) and t.a>'t-1'  order by lower(t.a);

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where lower(t.a)=lower(s.a) and lower(t.a)>'t-1'  order by t.a;

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where lower(t.a)=lower(s.a) and t.a>'t-1'  order by t.a;

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where lower(t.a)=s.a and t.a>'t-1'  order by t.a;

--Test
select /*+ recompile ordered */ t.a,s.a  from t,s where t.a=lower(s.a) and t.a>'t-1'  order by t.a;

drop table t;

drop table s;

set  system parameters 'dont_reuse_heap_file=no';

commit;

--+ holdcas off;


