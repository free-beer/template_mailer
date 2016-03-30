# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'template_mailer/version'

Gem::Specification.new do |spec|
  spec.name          = "template_mailer"
  spec.version       = TemplateMailer::VERSION
  spec.authors       = ["Peter Wood"]
  spec.email         = ["pwood@blacknorth.com"]
  spec.summary       = %q{A simple library that uses the Tilt and Pony libraries to generate and dispatch emails.}
  spec.description   = %q{Template Mailer is a library that can be used to send emails that are created from templates. It makes use of the Tilt library to support a wide variety of templating systems and the Pony library for integration with mail servers.}
  spec.homepage      = "https://github.com/free-beer/template_mailer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"

  spec.add_dependency "pony", "~> 1.11"
  spec.add_dependency "tilt", "~> 2.0"
end
