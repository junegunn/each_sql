# encoding: UTF-8
# Junegunn Choi (junegunn.c@gmail.com)

# Enumerable EachSQL object.
class EachSQL
	include Enumerable

	def initialize input, options
		raise NotImplementedError.new if options.nil?
		# immutables
		@org_input = input
		@options = options
		@blocks = @options[:blocks]
		@nblocks = @options[:nesting_blocks]
		@all_blocks = @blocks.merge @nblocks
	end

	def each
		@input = @org_input
		return nil if @input.nil? || @input.empty?

		@delimiter = @options[:delimiter]

		reset_cursor
		while @input
			# First look for next delimiter, this is to reduce the search space for blocks.
			extend_scope

			# We're done. Finished. Period. Out!
			break if scope.empty?

			# Extract a statement
			statement = extract_statement

			# When a non-empty statement is found
			statement = @options[:strip_delimiter].call self, statement if @options[:strip_delimiter]
			if statement.length > 0
				# Apply replacements
				@options[:replace].each do |k, v|
					statement.gsub!(k, v)
				end
				statement.strip!

				# Process callbacks
				@options[:callbacks].each do |pattern, callback|
					md = statement.match pattern
					callback.call self, statement, md if md
				end

				# Ignore
				if (@options[:ignore] || []).all? { |ipat| statement !~ ipat }
					yield statement
					@prev_statement = statement
				end
			end
		end
		nil
	end

	attr_accessor :delimiter, :delimiter_string
private

	def extract_statement
		while process_next_block != :not_found
		end

		ret = scope.strip
		@input = @input[@next_head..-1]
		reset_cursor
		return ret
	end

	def reset_cursor
		@cur = @from = @to = 0
	end

	def scope
		@to ? @input[0, @to] : @input
	end

	def extend_scope
		md = @input.match @delimiter, @to

		if md
			@to = md.begin(0) + md[0].length
			@next_head = @to
		else
			@to = @input.length
			@next_head = @input.length
		end
		#puts "Extended: #{scope.inspect} #{@input[@next_head..-1]}"
	end

	def process_next_block expect = nil
		# Look for the closest block
		block_start, opener_length, opener, closer = @all_blocks.map { |opener, closer|
			closer = closer[:closer] if closer.is_a? Hash
			md = scope.match(opener, @cur)
			[md && md.begin(0), md && md[0].length, opener, closer]
		}.reject { |e| e.first.nil? }.min_by(&:first)

		# p [scope, scope[@cur..-1], expect, scope.index(expect, @cur), block_start] if expect
		# We found a block, but after the end of the nesting block
		if expect &&
				(prev_end = scope.index(expect, @cur)) && 
				(block_start.nil? || prev_end <= block_start)
			skip_through_block expect, prev_end == block_start
			return :end_nest
		end
	
		# If no block in this scope
		return :not_found if block_start.nil?

		# We found a block. Look for the end of it
		@cur = block_start + opener_length

		# If nesting block, we go deeper
		if @nblocks.keys.include? opener
			@prev_delimiter = @delimiter
			if @nblocks[opener].is_a? Hash
				@delimiter = @nblocks[opener][:delimiter] || @delimiter
			end
			while true
				ret = process_next_block(closer)

				break if ret == :end_nest
				extend_scope if ret == :not_found
				throw_exception(closer) if scope.length == @input.length
			end
			@delimiter = @prev_delimiter

		# If non-nesting block, just skip through it
		else
			skip_through_block closer
		end

		return :continue
	end

	def skip_through_block closer, rewind_delimiter = false
		md = @input.match closer, @cur
		block_end = md && md.begin(0)

		throw_exception(closer) if block_end.nil?

		@cur = block_end + (rewind_delimiter ? 0 : md[0].length)
		while @cur > scope.length
			extend_scope
		end
	end

	def throw_exception closer
		raise ArgumentError.new(
				"Unclosed block: was expecting #{closer.inspect} " +
				"while processing #{$/ + scope.inspect}" + 
				(@prev_statement ?
					" after #{@prev_statement.inspect}" : ""))
	end
end#EachSQL

