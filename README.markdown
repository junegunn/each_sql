# each_sql

Enumerate executable blocks in the given SQL script.

## Installation
```
gem install 'each_sql'
```

## Example
### Basic
```ruby
require 'each_sql'

EachSQL(sql_script).each do |sql|
  puts sql
end

# .each can be omitted
EachSQL(sql_script) do |sql|
  puts sql
end

sqls = EachSQL(sql_script).to_a
```

### For scripts containing vendor-specific syntax
```ruby
# For MySQL script
EachSQL(mysql_script, :mysql).each do |sql|
  # ...
end

# For Oracle PL/SQL scripts
EachSQL(plsql_script, :oracle).each do |sql|
  # ...
end

# For PostgreSQL scripts
EachSQL(plpgsql_script, :postgres).each do |sql|
  # ...
end
```

## TODO
- More/better tests.
- Performance.

## Warning
Stored procedure handling is at best incomplete. Use it at your own risk.

## Contributing to each_sql
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Junegunn Choi. See LICENSE.txt for
further details.

