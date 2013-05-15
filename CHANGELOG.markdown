### 0.4.0 / 2013/05/15
* Returns an Enumerator instead of an Array when block is not given

### 0.3.1 / 2012/03/15
* Bug fix: `begin transaction`
* `EachSQL#clear`

### 0.3.0 / 2012/03/10
* Internal implementation revised.
 * At first, I thought this would be trivial,
   that I didn't need a real parser for just breaking SQL scripts
   into individual executable units.
   I couldn't be more wrong. Codes for handling a few exceptional cases
   soon piled up and became unmaintainable.
   The new version now employs Citrus parser for processing SQL scripts.
   The output is not backward-compatible, for instance, comments before and after
   each execution block are trimmed out.
* Supports PostgreSQL (experimental)
* `delimiter` command works for all types

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

