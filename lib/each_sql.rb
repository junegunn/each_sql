# encoding: UTF-8
# Junegunn Choi (junegunn.c@gmail.com)

require 'each_sql/each_sql'

# Shortcut method for creating a Enumerable EachSQL object for the given input.
# @param[String] input Input script.
# @param[Symbol] The type of the input SQL script. :default, :mysql, and :oracle (or :plsql)
# @return[EachSQL] Enumerable 
def EachSQL input, type = :default
	EachSQL.new(input, EachSQL::Defaults[type])
end

class EachSQL
	# EachSQL::Default Hash is a set of pre-defined parsing rules
	# - :default: Default parsing rules for vendor-independent SQL scripts
	# - :mysql:   Parsing rules for MySQL scripts. Understands `delimiter' statements.
	# - :oracle:  Parsing rules for Oracle scripts. Removes trailing slashes after begin-end blocks.
	Defaults = {
		:default => {
			:delimiter => /;+/,
			:blocks => {
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bdeclare\b/i => /\bbegin\b/i,
				/\bbegin\b/i => /\bend\b/i
			},
			:callbacks => {},
			:ignore    => [],
			:replace   => {},
			# Let's assume we don't change delimiters within usual sql scripts
			:strip_delimiter => lambda { |obj, stmt| stmt.chomp ';' }
		},

		:mysql => {
			:delimiter => /;+|delimiter\s+\S+/i,
			:blocks => {
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\b/i
			},
			# We need to change delimiter on `delimiter' command
			:callbacks => {
				/^\s*delimiter\s+(\S+)/i => lambda { |obj, stmt, md|
					new_delimiter = Regexp.new(Regexp.escape md[1])
					obj.delimiter = /#{new_delimiter}+|delimiter\s+\S+/i
					obj.delimiter_string = md[1]
				}
			},
			:ignore => [
				/^delimiter\s+\S+$/i
			],
			:replace => {},
			:strip_delimiter => lambda { |obj, stmt|
				stmt.chomp(obj.delimiter_string || ';')
			}
		},

		:oracle => {
			:delimiter => /;+/,
			:blocks => {
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\b/i,
				/\bcreate[^;]*\b(procedure|function|trigger|package)\b/im => {
					:closer => %r{;\s*/}m,
					:delimiter => /;\s*\//
				}
			},
			:callbacks => {},
			:ignore => [],
			:replace => {},
			:strip_delimiter => lambda { |obj, stmt| obj 
				stmt.chomp( stmt =~ /;\s*\// ? '/' : ';' )
			}
		},

		:postgres => {
			:delimiter => /;+/,
			:blocks => {
				/'/          => /'/,
				/\/\*/       => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\b/i
			},
			:callbacks => {},
			:ignore    => [],
			:replace   => {},
			:strip_delimiter => lambda { |obj, stmt| stmt.chomp ';' }
		},

	}
	Defaults[:plsql] = Defaults[:oracle] # alias

	# Freeze the Hash
	Defaults.freeze
end

