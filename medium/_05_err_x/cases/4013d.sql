autocommit off;
create class bar (y int);
create vclass foo (b set(float)) 
	as select y from bar;
insert into bar values ({1});
insert into bar values ({'a'});
select * from foo;
rollback;
