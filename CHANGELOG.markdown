### 0.3.0 / 2012/03/10
* I thought this would be trivial, thought that I didn't need a real parser for
  just breaking SQL scripts into individual statements that could be run.
  But I couldn't be more wrong. Codes for handling a few exceptional cases
  soon piled up and became unmaintainable.
  This new version now employs Citrus parser for handling SQL scripts.
  The output is not backward-compatible, for example, comments before and after
  each execution block are trimmed out.

### 0.2.5 / 2011/09/01
* Can pass block directly to EachSQL(script)

```ruby
EachSQL(script) do |sql|
  # ...
end
```

### 0.2.4 / 2011/08/04
* Bug fix: Strip semicolons at both ends

### 0.2.3 / 2011/07/08
* Bug fix: Two Oracle PL/SQL parsing errors fixed

### 0.2.2 / 2011/06/21
* Bug fix: Error on nil/empty input

### 0.2.1 / 2011/06/20
* Fixed invalid gem packaging

### 0.2.0 / 2011/06/17
* Second release. Handles more cases.
* Ruby 1.8 compatible

### 0.1.0 / 2011/06/15
* Initial release. Turned out to be very flawed :p

