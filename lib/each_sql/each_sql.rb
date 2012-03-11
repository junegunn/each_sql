# Enumerable EachSQL object.
class EachSQL
  include Enumerable

  def initialize type
    @type   = type
    @data   = ''
    @sqls   = []

    self.delimiter = ';'
  end

  def delimiter= delim
    @delim = delim
    @parser = EachSQL::Parser.parser_for @type, delim
  end

  def << input
    if input
      @data << input.sub(/\A#{[65279].pack('U*')}/, '') # BOM (FIXME)
    end
    self
  end

  # @return [Hash]
  def shift
    result = @parser.parse @data
    # puts result.dump
    @data  = result[:leftover].join
    {
      :sqls =>
        result.captures[:execution_block].map { |sql| strip_sql sql },
      :leftover =>
        result.captures[:leftover].map { |lo| strip_sql lo }.reject(&:empty?)
    }
  end

  # @return [Boolean]
  def empty?
    @data.gsub(/\s/, '').empty?
  end

  # @yield [String]
  # @return [NilClass]
  def each
    result = shift
    sqls = (result[:sqls] + result[:leftover]).reject { |sql|
      strip_sql(sql).empty?
    }
    sqls.each do |sql|
      yield sql
    end
  end

  private

  def strip_sql sql
    prev_sql = nil
    while prev_sql != sql
      prev_sql = sql
      sql = sql.strip.gsub(/\A(#{Regexp.escape @delim})+/, '').
                      gsub(/(#{Regexp.escape @delim})+\Z/, '').strip
    end
    prev_sql
  end
end#EachSQL

