--Create hash partition and retrieve information from db_partition
create class test_class (
    line_id   varchar(10)  not null,
    station_id    integer,
    station_name  varchar(30)
)
partition by hash (station_id)
partitions 4;

insert into test_class values ('Line 1', 1021, 'Dongdaemoon');
insert into test_class values ('Line 1', 1031, 'Byoungjum');
insert into test_class values ('Line 2', 2001, 'Kangnam');
insert into test_class values ('Line 2', 2002, 'Kangbyun');
insert into test_class values ('Line 2', 2003, 'Kunkook Univ.');
insert into test_class values ('Line 3', 3002, 'Bus_terminal');
insert into test_class values ('Line 3', 3003, 'Education Univ.');
insert into test_class values ('Line 4', 4004, 'Guachon');
insert into test_class values ('Line 4', 4005, 'Kumjung');
insert into test_class values ('Line 5', 5001, 'Kangdong');

select * from db_partition
where class_name = 'test_class' order by 1,2,3;

drop class test_class;