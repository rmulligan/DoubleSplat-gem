# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doublesplat/version'

Gem::Specification.new do |spec|
  spec.name          = "doublesplat"
  spec.version       = Doublesplat::VERSION
  spec.authors       = ["Ryan Mulligan"]
  spec.email         = ["mullymulligan@gmail.com"]
  spec.summary       = %q{Battle other ruby coders for real cash using your own editor.}
  spec.description   = %q{}
  spec.homepage      = "http://www.doublesplat.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["splat"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rainbow"
  spec.add_dependency "rest-client"
  spec.add_dependency "listen"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "awesome_print"
end
