require 'citrus'
require 'erubis'
require 'quote_unquote'

class EachSQL
module Parser
  @@parser = {}
  # @param[Symbol] type RDBMS type: :default|:mysql|:oracle|:postgres
  # @param[String] delimiter SQL delimiter
  # @return[Module] Citrus parser
  def self.parser_for type, delimiter = ';'
    # Is there any better way of handling dynamic changes?

    return @@parser[[type, delimiter]] if @@parser[[type, delimiter]]

    path   = File.join( File.dirname(__FILE__), 'parser/sql.citrus.erb' )
    erb    = Erubis::Eruby.new( File.read path )
    suffix = @@parser.length.to_s

    Citrus.eval erb.result(binding)

    @@parser[[type, delimiter]] = 
      case type
      when :default
        eval "EachSQL::Parser::Default#{suffix}"
      when :mysql
        eval "EachSQL::Parser::MySQL#{suffix}"
      when :oracle
        eval "EachSQL::Parser::Oracle#{suffix}"
      when :postgres, :postgresql
        eval "EachSQL::Parser::PostgreSQL#{suffix}"
      else
        raise NotImplementedError.new(
          "Parser not implemented for #{type}. Try use :default instead.")
      end
  end
end#Parser
end#EachSQL

