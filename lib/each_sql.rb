# encoding: UTF-8
# Junegunn Choi (junegunn.c@gmail.com)

require 'each_sql/each_sql'

# Shortcut method for creating a Enumerable EachSQL object for the given input.
# @param[String] input Input script.
# @param[Symbol] The type of the input SQL script. :default, :mysql, and :oracle (or :plsql)
# @return[EachSQL] Enumerable 
def EachSQL input, type = :default
	EachSQL.new(input, EachSQL::Default[type])
end

class EachSQL
	# EachSQL::Default Hash is a set of pre-defined parsing rules
	# - :default: Default parsing rules for vendor-independent SQL scripts
	# - :mysql:   Parsing rules for MySQL scripts. Understands `delimiter' statements.
	# - :oracle:  Parsing rules for Oracle scripts. Removes trailing slashes after begin-end blocks.
	Default = {
		:default => {
			:delimiter => ';',
			:blocks => {
				/'/          => /'/,
				/\/\*/       => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\s*;/i
			},
			:ignore    => [],
			:callbacks => {},
			:replace   => {},
			:strip_delimiter => true,
		}
	}

	# SQL parsing rules for MySQL scripts
	Default[:mysql] = Default[:default].merge(
		{ 
			:callbacks => {
				/^delimiter\s+(.*)$/i => 
						lambda { |obj, stmt, match|
							obj.delimiter = match[1]
						}
			},
			:ignore => [
				/^delimiter\s+.*$/i
			]
		})

	# SQL parsing rules for Oracle scripts
	Default[:oracle] = Default[:default].merge(
		{
			:replace => {
				%r{^/} => ''
			}
		})
	Default[:oracle][:nesting_blocks][
		/\bcreate[^;]*\b(procedure|function|trigger|package)\b/im] = %r{;\s*/}m

	Default[:plsql] = Default[:oracle] # alias

	# Freeze the Hash
	Default.freeze
end

