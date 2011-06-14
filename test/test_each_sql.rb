$LOAD_PATH << 'test'
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
	*
from
	d",
"select * from /* block comment ; */ e",
"select * 
from -- line comment ; /* ;; */
f",
"-------------- begin-end block;

create or replace something as
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
create or replace procedure tmmp(p1 number, p2 number) as
    str varchar2(4000);
begin
	begin
		null;
	end;
exception
    when others then
        raise;
end;
/
select * from dual;"

	end

	def test_sql
		script = @sql.map { |e| e.strip + ';' }.join $/
		EachSQL(script).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
			#assert_equal @sql[idx], sql
		end
		#assert_equal EachSQL(@sql).to_a, EachSQL(@sql).map { |e| e }
	end
	
	def t_est_oracle
		EachSQL(@oracle, :oracle).each_with_index do |sql,idx|
			puts sql
			puts '-' * 40
		end
	end

	def test_mysql
	end

end
