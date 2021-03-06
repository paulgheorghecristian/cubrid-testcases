--[er]Create unique index with keyword asc/desc and datatype:set, multiset, list , sequence
create class ddl_0001( col1 set char(5) , col2 multiset varchar(10), col3 list int, col4 sequence int, col5 set date  );
insert into ddl_0001 values({'a','b','c'}, {'a','b','c'}, {1,2,3}, {11,11,11},{sysdate,sysdate,sysdate});
insert into ddl_0001 values({'b','b','c'}, {'b','b','c'}, {2,2,3}, {12,11,11},{null,sysdate,sysdate});
insert into ddl_0001 values({'c','b','c'}, {'c','b','c'}, {3,2,3}, {13,11,11},{null,null,sysdate});
insert into ddl_0001 values({'d','b','c'}, {'d','b','c'}, {4,2,3}, {14,11,11},{sysdate,null,sysdate});
insert into ddl_0001 values({'e','b','c'}, {'e','b','c'}, {5,2,3}, {15,11,11},{sysdate,sysdate,null});
insert into ddl_0001 values({'f','b','c'}, {'f','b','c'}, {6,2,3}, {16,11,11},{sysdate,null,null});
insert into ddl_0001 values({'g','b','c'}, {'g','b','c'}, {7,2,3}, {17,11,11},{null,null,null});
insert into ddl_0001 values({'h','b','c'}, {'h','b','c'}, {8,2,3}, {18,11,11},{sysdate,sysdate,sysdate});
create unique index ddl_0001_idx0 on ddl_0001(col1 asc);
create unique index ddl_0001_idx1 on ddl_0001(col2 asc);
create unique index ddl_0001_idx2 on ddl_0001(col3 desc);
create unique index ddl_0001_idx3 on ddl_0001(col4 asc);
create unique index ddl_0001_idx4 on ddl_0001(col5 desc);
create unique index ddl_0001_idx5 on ddl_0001(col1 asc,col2 desc, col3 desc, col4 asc);
create unique index ddl_0001_idx6 on ddl_0001(col5 desc, col1 asc, col2 desc);
create unique index ddl_0001_idx7 on ddl_0001(col4 desc, col1 asc, col4 desc);
select inde_name from db_index where class_name='ddl_0001' order by 1;
drop class ddl_0001;
