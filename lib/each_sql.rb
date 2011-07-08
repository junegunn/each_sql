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
				/`/          => /`/,
				/"/          => /"/,
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bdeclare.*?;\s*?begin\b/im => /;\s*?end\b/i,
				/\bbegin\b/i => /;\s*?end\b/i,
			},
			:nesting_context => [
				/\A\s*(begin|declare|create\b[^;]+?\b(procedure|function|trigger|package))\b/im
			],
			:callbacks => {},
			:ignore    => [],
			:replace   => {},
			# Let's assume we don't change delimiters within usual sql scripts
			:strip_delimiter => lambda { |obj, stmt| stmt.chomp ';' }
		},

		:mysql => {
			:delimiter => /;+|delimiter\s+\S+/i,
			:blocks => {
				/`/          => /`/,
				/"/          => /"/,
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\b/i
			},
			:nesting_context => [
				/\A\s*(begin|create\b[^;]+?\b(procedure|function|trigger))\b/im
			],
			# We need to change delimiter on `delimiter' command
			:callbacks => {
				/^\s*delimiter\s+(\S+)/i => lambda { |obj, stmt, md|
					new_delimiter = Regexp.new(Regexp.escape md[1])
					obj.delimiter = /(#{new_delimiter})+|delimiter\s+\S+/i
					obj.delimiter_string = md[1]
				}
			},
			:ignore => [
				/^delimiter\s+\S+$/i
			],
			:replace => {},
			:strip_delimiter => lambda { |obj, stmt|
				stmt.gsub(/(#{Regexp.escape(obj.delimiter_string || ';')})+\Z/, '')
			}
		},

		:oracle => {
			:delimiter => /;+/,
			:blocks => {
				/`/          => /`/,
				/"/          => /"/,
				/'/          => /'/,
				/\/\*[^+]/   => /\*\//,
				/--+/        => $/,
			},
			:nesting_blocks => {
				/\bbegin\b/i => /\bend\b/i,
				/\bdeclare.*?;\s*?begin\b/im => {
					:closer => %r{;\s*/}m,
					# Stops immediately
					:pop => true
				},
				/\bcreate[^;]+?\b(procedure|function|trigger|package)\b/im => {
					:closer => %r{;\s*/}m,
					# Stops immediately
					:pop => true
				}
			},
			:nesting_context => [
				/\A\s*(\/\s*)*(begin|declare|create\b[^;]+?\b(procedure|function|trigger|package))\b/im
			],
			:callbacks => {
				/\Abegin\b/ => lambda { |obj, stmt, md|
					# Oracle needs this
					stmt << ';' if stmt !~ /;\Z/
				}
			},
			:ignore => [],
			:replace => { %r[\A/] => '' },
			:strip_delimiter => lambda { |obj, stmt|
				stmt.gsub(/(#{stmt =~ /;\s*\// ? '/' : ';'})+\Z/, '')
			}
		}
	}
	Defaults[:plsql] = Defaults[:oracle] # alias

	# Freeze the Hash
	Defaults.freeze
end

