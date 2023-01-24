# frozen_string_literal: true

require_relative 'lib/api_frame/version'

Gem::Specification.new do |spec|
	spec.name    = 'api_frame'
	spec.version = ApiFrame::VERSION
	spec.authors = ['expeehaa']
	spec.email   = ['expeehaa@outlook.com']
	spec.summary = 'Small framework to define API clients in Ruby'
	
	spec.homepage = 'https://github.com/expeehaa/api_frame'
	
	spec.metadata['allowed_push_host'    ] = 'https://rubygems.org'
	spec.metadata['rubygems_mfa_required'] = 'true'
	
	spec.files         = Dir['lib/**/*.rb', 'README.adoc']
	spec.require_paths = ['lib']
	
	spec.required_ruby_version = '>= 2.6.0'
end
