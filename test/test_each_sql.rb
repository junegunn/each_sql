# encoding: UTF-8

$LOAD_PATH << File.dirname(__FILE__)
require 'helper'

class TestEachSql < Test::Unit::TestCase
	def setup
	@sql = [
"-------------- begin-end block;
declare
	/* end; */
	/* begin */
	null;
	null;
	null;
begin
	/* end */
	null;
end",
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
"select b `begin` from dual",
'select b "begin" from dual',
'select 
	begin , begin.* from begin'
]

	@oracle = [
'select * from dual',
'create /* procedure */ sequence a',
"create package something as
	procedure log;
	procedure log;
	procedure log;
end something;",
"Create or replace Procedure tmmp(p1 number default 'begin', p2 number) as
    str number(8, 2) := 1 / 4;
begin
	1 / 2;
	begin
		1 / 4;
		null;
	end;
exception
    when others then
        raise;
end;",
"-- declaration
declare
	a int;
begin
	1 / 2;
	begin
		1 / 4;
		null;
	end;
exception
    when others then
        raise;
end;",
"begin
	null;
end;",
"begin
        null;
    end;",
"select * from dual",
"select begin, end, create, procedure, end, from dual",
"select * from dual",
"-- TMP_DB_TOOLS_CONV
        begin
            execute immediate 'DROP TABLE TMP_DB_TOOLS_CONV CASCADE CONSTRAINTS';
        exception
            when others then
                null;
        end;"
	]
		
	@oracle_script = "
select * from dual;
;;;;;;;
;;;
;;

create /* procedure */ sequence a;
create package something as
	procedure log;
	procedure log;
	procedure log;
end something;
/

Create or replace Procedure tmmp(p1 number default 'begin', p2 number) as
    str number(8, 2) := 1 / 4;
begin
	1 / 2;
	begin
		1 / 4;
		null;
	end;
exception
    when others then
        raise;
end;
/
-- declaration
declare
	a int;
begin
	1 / 2;
	begin
		1 / 4;
		null;
	end;
exception
    when others then
        raise;
end;
/
begin
	null;
end;
/
    begin
        null;
    end;
    /
select * from dual;
;
;
;


;;;;;;
;

select begin, end, create, procedure, end, from dual;
select * from dual;

        -- TMP_DB_TOOLS_CONV
        begin
            execute immediate 'DROP TABLE TMP_DB_TOOLS_CONV CASCADE CONSTRAINTS';
        exception
            when others then
                null;
        end;
        /
"

	@mysql = [
"drop procedure if exists proc",
"create procedure proc(p1 int, p2 int)
begin
    null;
	begin
		null;
	end;
end",
"drop procedure if exists proc2",
"create procedure proc(p1 int, p2 int)
begin
    null;

end",
"select * from dual",
"select b `begin` from dual",
'select b "begin" from dual',
'select 
	begin , begin.* from begin'
	]
	@mysql_script = "
delimiter //
drop procedure if exists proc //
create procedure proc(p1 int, p2 int)
begin
    null;
	begin
		null;
	end;
end //
delimiter ;

delimiter $$
drop procedure if exists proc2 $$
create procedure proc(p1 int, p2 int)
begin
    null;

end $$
delimiter ;

select * from dual;;;;;
;;;select b `begin` from dual;
select b \"begin\" from dual;
select 
	begin , begin.* from begin"
	end

	def test_sql
		[nil, "", " \n" * 10].each do |input|
			EachSQL(input).each do |sql|
				assert false, 'Should not enumerate'
			end

			EachSQL(input) do |sql|
				assert false, 'Should not enumerate'
			end

      # Directly pass block
			EachSQL(input) do |sql|
				assert false, 'Should not enumerate'
			end
			assert true, 'No error expected'
		end

		script = @sql.map { |e| e.strip + ';;;;' }.join $/
		EachSQL(script).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
			assert_equal @sql[idx], sql
		end
		assert_equal EachSQL(script).to_a, EachSQL(script).map { |e| e }
	end
	
	def test_oracle
		EachSQL(@oracle_script, :oracle).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
			assert_equal @oracle[idx], sql
		end
	end

	def test_mysql
		EachSQL(@mysql_script, :mysql).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
			assert_equal @mysql[idx], sql
		end
	end

	def _test_postgres
		EachSQL(File.read(File.dirname(__FILE__) + '/postgres.sql'), :postgres).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
		end
	end
end
