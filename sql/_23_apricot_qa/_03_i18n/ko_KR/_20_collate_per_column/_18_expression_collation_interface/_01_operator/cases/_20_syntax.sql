--+ holdcas on;
set names utf8;
create table t1 (s1 string charset utf8 collate 'utf8_ko_cs_uca');
insert into t1 values ('가'),( '伽');
create table t2 (a int AUTO_INCREMENT , s1 string charset utf8 collate 'utf8_bin');
insert into t2 (s1)values select * from t1 order by 1;
select * from t2 order by s1;
select * from t1 order by s1;
drop t1,t2;
set names iso88591;
commit;
--+ holdcas off;