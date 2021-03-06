--+ holdcas on;
set names utf8;
set system parameters 'intl_number_lang = de_DE';
set system parameters 'intl_date_lang = de_DE';
create table t( a DATE);
insert into t value(STR_TO_DATE('Sonntag 2 2011','%W %u %Y'));
insert into t value(STR_TO_DATE('SoNNtag 2 2011','%W %u %Y'));
insert into t value(STR_TO_DATE('Jan 1, 2013','%b %d,%Y'));
insert into t value(STR_TO_DATE('JaN 1, 2013','%b %d,%Y'));
insert into t value(STR_TO_DATE('So. 2 2011','%a %u %Y'));
insert into t value(STR_TO_DATE('SO. 2 2011','%a %u %Y'));
insert into t value(STR_TO_DATE('Januar 1, 2013','%M %d,%Y'));
insert into t value(STR_TO_DATE('JanUAR 1, 2013','%M %d,%Y'));
select * from t order by 1;
drop table t;
set system parameters 'intl_date_lang = en_US';
set system parameters 'intl_number_lang = en_US';
set names iso88591;
commit;
--+ holdcas off;