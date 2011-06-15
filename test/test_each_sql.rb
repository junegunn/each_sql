$LOAD_PATH << File.dirname(__FILE__)
require 'helper'

class TestEachSql < Test::Unit::TestCase
	def setup
	@sql = [
"select * from a",
"select
	*
from
	b",
"select 'abc', 'abc;', 'abc''', 'abc/*', 'abc--' from c",

"select
	/*+ help */ *
from
	d",
"select * from /* block comment ; */ e",
"select * 
from -- line comment ; /* ;; */
f",
"-------------- begin-end block;
begin
	-- begin-end block;
	-- line comment
	-- line comment
	-- line comment
	begin
		null;
		begin
			null;
		end;
	end;
	-- end
	/* end */
end",
"-------------- begin-end block;
declare
	/* end; */
	/* begin */
	null;
	null;
	null;
begin
	/* end */
end",
"-------------- begin-end block;
declare
	/* end; */
	/* begin */
	null;
	null;
	null;
begin
	-- begin-end block;
	-- line comment
	-- line comment
	-- line comment
	begin
		null;
		begin
			null;
		end;
	end;
	-- end
	/* end */
end",
"select * from dual",
"select * from dual"]

	@oracle = "
select * from dual;
Create or replace Procedure tmmp(p1 number, p2 number) as
    str number(8, 2) := 1 / 4;
begin
	begin
		1 / 4;
		null;
	end;
exception
    when others then
        raise;
end;
/
select * from dual;"

	@mysql = "
delimiter //
drop procedure if exists proc //
create procedure proc(p1 int, p2 int)
begin
    null;

end //
delimiter ;

delimiter $$
drop procedure if exists proc2 $$
create procedure proc(p1 int, p2 int)
begin
    null;

end $$
delimiter ;

select * from dual;"
	end

	def test_sql
		script = @sql.map { |e| e.strip + ';' }.join $/
		EachSQL(script).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
			assert_equal @sql[idx], sql
		end
		assert_equal EachSQL(script).to_a, EachSQL(script).map { |e| e }
	end
	
	def test_oracle
		EachSQL(@oracle, :oracle).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
		end
	end

	def test_mysql
		EachSQL(@mysql, :mysql).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
		end
	end

	def _test_postgres
		EachSQL(File.read(File.dirname(__FILE__) + '/postgres.sql'), :postgres).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
		end
	end
end
