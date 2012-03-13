# encoding: UTF-8

$LOAD_PATH << File.dirname(__FILE__)
require 'helper'
require 'yaml'

class TestEachSql < Test::Unit::TestCase
  def _test_empty
		[nil, "", " \n" * 10].each do |input|
			EachSQL(input).each do |sql|
        p sql
				assert false, 'Should not enumerate'
			end

      # Directly pass block
			EachSQL(input) do |sql|
				assert false, 'Should not enumerate'
			end
			assert true, 'No error expected'
		end
  end

  def _test_parser_cache
    [:default, :mysql, :oracle, :postgres].each do |typ|
      %w[';', '$$', '//'].each do |delim|
        arr = 
          10.times.map {
            EachSQL::Parser.parser_for typ, delim
          }
        p arr
        assert_equal 10, arr.length
        assert_equal 1, arr.uniq.length
      end
    end

  end

	def test_sql
    common = YAML.load(
                     File.read(
                       File.join(
                         File.dirname(__FILE__), "yml/common.yml")))
    [:default, :mysql, :oracle, :postgres].each do |typ|
      data = YAML.load(
               File.read(
                 File.join(
                   File.dirname(__FILE__), "yml/#{typ}.yml")))

      script = nil
      [common, data].each do |d|
        script = d['all']
        EachSQL(script, typ).each_with_index do |sql, idx|
          expect = d['each'][idx].chomp
          puts sql
          puts '-' * 40
          if typ == :oracle
            assert expect == sql || sql == expect + ';',
              [expect, 'x' * 80, sql].join($/)
          else
            assert_equal expect, sql
          end
        end
      end

      cnt = 0
      EachSQL(script, typ) do |sql|
        cnt += 1
      end
      assert_equal data['each'].length, cnt
      assert_equal cnt, EachSQL(script, typ).to_a.length
      assert_equal EachSQL(script, typ).to_a, EachSQL(script, typ).map { |e| e }
    end
	end
	
	# def test_oracle
	# 	EachSQL(@oracle_script, :oracle).each_with_index do |sql,idx|
	# 		puts sql
	# 		puts '-' * 40
	# 		assert_equal @oracle[idx], sql
	# 	end
	# end

	# def test_mysql
	# 	EachSQL(@mysql_script, :mysql).each_with_index do |sql,idx|
	# 		puts sql
	# 		puts '-' * 40
	# 		assert_equal @mysql[idx], sql
	# 	end
	# end

	# def _test_postgres
	# 	EachSQL(File.read(File.dirname(__FILE__) + '/postgres.sql'), :postgres).each_with_index do |sql,idx|
	# 		puts sql
	# 		puts '-' * 40
	# 	end
	# end
end
