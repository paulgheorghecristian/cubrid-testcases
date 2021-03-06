--+ holdcas on;
set  system parameters 'dont_reuse_heap_file=yes';
create table t1(  a char(1200),   b varchar(1200),  c nchar(1200),  d NCHAR VARYING(1200),  e BIT(1200),  f BIT VARYING(1200),  g int,  h SMALLINT,  i BIGINT,  j NUMERIC,  k FLOAT,  l DOUBLE,  m MONETARY,  n DATE,  o TIME,  p TIMESTAMP,  q DATETIME);

insert into t1 values (
  '1234567890',
  '1234567890',
  N'abc',
  N'ABC',
  B'1111111111',
  B'1111111111',
  10,
  255,
  9223372036854775807,
  0,
  0,
  0,
  -100,
  DATE '2008-10-31',
  TIME '00:00:00',
  TIMESTAMP '2010-10-31 01:15:45',
  DATETIME  '2008-10-31 13:15:45');

create index i_t1_a2a on t1(LOWER(b));


--TEST: should use i_t1_a2a
select /*+ RECOMPILE */ count(length(a)),10 from t1 where exists (select t1.a from t1 where LOWER(b)>'0');
--TEST: should use i_t1_a2a
select /*+ RECOMPILE */ count(length(a)),10 from t1 where exists (select t1.a) and LOWER(b)>'0';
--TEST: should not use i_t1_a2a
select /*+ RECOMPILE */ count(length(a)),10 from t1 where exists (select t1.a) or LOWER(b)>'0';

drop table t1;
set  system parameters 'dont_reuse_heap_file=no';
commit;
--+ holdcas off;
