# encoding: UTF-8
# Junegunn Choi (junegunn.c@gmail.com)

require 'rubygems'
require 'each_sql/each_sql'
require 'each_sql/parser'

# Shortcut method for creating a Enumerable EachSQL object for the given input.
# @param[String] input Input script.
# @param[Symbol] The type of the input SQL script. :default, :mysql, and :oracle (or :plsql)
# @return[Array] Array of executable SQL statements and blocks.
def EachSQL input, type = :default
  esql   = EachSQL.new(type)
  ret    = []
  result = { :leftover => [] }
  input.to_s.each_line do |line|
    if (md = line.match(/^\s*delimiter\s+(\S+)/i)) && esql.empty?
      esql.delimiter = md[1]
      next
    end

    esql << line
    result = esql.shift
    sqls   = result[:sqls]
    sqls.each do |sql|
      if block_given?
        yield sql
      else
        ret << sql
      end
    end
  end

  result[:leftover].each do |sql|
    if block_given?
      yield sql
    else
      ret << sql
    end
  end
  ret
end

