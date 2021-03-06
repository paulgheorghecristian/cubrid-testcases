--[er]test insert(string) for list partition(have NULL value) with incorrect values out of range
create table list_test(id int ,                     
			test_char char(50),                              
			test_varchar varchar(2000),                      
			test_bit bit(16),                                
			test_varbit bit varying(20),                     
			test_nchar nchar(50),                            
			test_nvarchar nchar varying(2000),               
			test_string string,                              
			test_datetime timestamp, primary key(id,test_string))                         
PARTITION BY LIST (test_string) (                                        
    PARTITION p0 VALUES IN ('aaaaaaaaaa','bbbbbbbbbb','dddddddddd',NULL) 
);                                                                       


insert into list_test values(4,'ccc','ccc',B'11',B'1101',N'ccc',N'ccc','cccccccccc','2006-03-01 09:00:00');
select * from list_test order by 1;


drop table list_test;
