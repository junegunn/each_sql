# encoding: UTF-8

$LOAD_PATH << File.dirname(__FILE__)
require 'helper'
require 'yaml'

class TestEachSql < Test::Unit::TestCase
  def test_each_sql
    esql = EachSQL.new(:default)
    esql << "select"
    result = esql.shift
    assert_equal 0, result[:sqls].length
    assert_equal 'select', result[:leftover]

    esql << " * from table1; select * from table2;"
    result = esql.shift
    assert_equal ['select * from table1', 'select * from table2'], result[:sqls]
    assert_equal nil, result[:leftover]

    esql << "select * from table3;"
    assert_equal esql, esql.clear
    result = esql.shift
    assert_equal 0, result[:sqls].length
    assert_equal nil, result[:leftover]
  end

  # Acceptance tests
  # ================
  def test_empty
		[nil, "", " \n" * 10].each do |input|
			EachSQL(input).each do |sql|
				assert false, 'Should not enumerate'
			end

      # Directly pass block
			EachSQL(input) do |sql|
				assert false, 'Should not enumerate'
			end
			assert true, 'No error expected'
		end
  end

  def test_parser_cache
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
end
