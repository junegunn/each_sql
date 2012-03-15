require 'stringio'

# Enumerable EachSQL object.
class EachSQL
  include Enumerable

  # @param[Symbol] type RDBMS type: :default|:mysql|:oracle|:postgres
  # @param[String] delimiter Script delimiter.
  def initialize type, delimiter = ';'
    @type   = type
    @data   = ''
    @sqls   = []

    self.delimiter = delimiter
  end

  # @param[String] delim SQL delimiter
  # @return[EachSQL]
  def delimiter= delim
    @delim = delim
    @parser = EachSQL::Parser.parser_for @type, delim
    self
  end

  # @return[String] Current delimiter.
  def delimiter
    @delim
  end

  # Appends the given String to the buffer.
  # @param[String] input String to append
  def << input
    if input
      @data << input.sub(/\A#{[65279].pack('U*')}/, '') # BOM (FIXME)
    end
    self
  end

  # Clears the buffer
  # @return [EachSQL]
  def clear
    @data = ''
    self
  end

  # Parses current buffer and returns the result in Hash.
  # :sqls is an Array of processed executable SQL blocks,
  # :leftover is the unparsed trailing data
  # @return [Hash]
  def shift
    result   = @parser.parse @data
    @data    = result.captures[:leftover].join
    leftover = strip_sql(@data)
    {
      :sqls =>
        result.captures[:execution_block].map { |b| strip_sql b },
      :leftover => leftover.empty? ? nil : leftover
    }
  end

  # Return is the buffer is empty
  # @return [Boolean]
  def empty?
    @data.gsub(/\s/, '').empty?
  end

  # Parses the buffer and enumerates through the executable blocks.
  # @yield [String]
  # @return [NilClass]
  def each
    result = shift
    sqls   = (result[:sqls] + result[:leftover]).
              map { |sql| strip_sql(sql) }.
              reject(&:empty?)
    sqls.each do |sql|
      yield sql
    end
  end

  private
  def strip_sql sql
    # Preprocess
    case @type
    when :oracle
      sql = sql.sub(/\A[\s\/]+/, '').sub(/[\s\/]+\Z/, '')
    end

    # FIXME: Infinite loop?
    # sql = sql.gsub(
    #         /
    #          (?:
    #            (?:\A(?:#{Regexp.escape @delim}|[\s]+)+)
    #            |
    #            (?:(?:#{Regexp.escape @delim}|[\s]+)+\Z)
    #          )+
    #         /x, '')
    prev_sql = nil
    delim = Regexp.escape @delim
    while prev_sql != sql
      prev_sql = sql
      sql = sql.strip.sub(/\A(?:#{delim})+/, '').sub(/(?:#{delim})+\Z/, '')
    end

    # Postprocess
    case @type
    when :oracle
      if sql =~ /\bend(\s+\S+)?\Z/i
        sql = sql + ';'
      end
    end

    sql
  end

end#EachSQL

