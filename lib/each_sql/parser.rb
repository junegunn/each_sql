require 'citrus'
require 'erubis'
require 'quote_unquote'

class EachSQL
module Parser
  @@counter = 0
  def self.parser_for type, delimiter = ';'
    # Is there any better way of handling dynamic changes?

    path   = File.join( File.dirname(__FILE__), 'parser/sql.citrus.erb' )
    erb    = Erubis::Eruby.new( File.read path )
    suffix = (@@counter += 1).to_s

    Citrus.eval erb.result(binding)

    case type
    when :default
      eval "EachSQL::Parser::Default#{suffix}"
    when :mysql
      eval "EachSQL::Parser::MySQL#{suffix}"
    when :oracle
      eval "EachSQL::Parser::Oracle#{suffix}"
    else
      raise NotImplementedError.new(
        "Parser not implemented for #{type}. Try use :default instead.")
    end
  end

end#Parser
end#EachSQL

