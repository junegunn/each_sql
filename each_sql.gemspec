# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "each_sql"
  spec.version       = "0.4.1"
  spec.authors       = ["Junegunn Choi"]
  spec.email         = ["junegunn.c@gmail.com"]
  spec.description   = %q{Enumerate each SQL statement in SQL scripts.}
  spec.summary       = %q{Enumerate each SQL statement in SQL scripts.}
  spec.homepage      = "https://github.com/junegunn/each_sql"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'citrus', '~> 2.4.1'
  spec.add_runtime_dependency 'erubis', '~> 2.7.0'
  spec.add_runtime_dependency 'quote_unquote', '~> 0.1.1'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
