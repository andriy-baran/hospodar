# frozen_string_literal: true

require_relative 'lib/hospodar/version'

Gem::Specification.new do |spec|
  spec.name          = 'hospodar'
  spec.version       = Hospodar::VERSION
  spec.authors       = ['Andrii Baran']
  spec.email         = ['andriy.baran.v@gmail.com']

  spec.summary       = 'Create complex object easily'
  spec.description   = 'Simple DSL that supports creating complex strutures of objects'
  spec.homepage      = 'https://github.com/andriy-baran/hospodar'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/andriy-baran/hospodar/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-inflector', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry', '0.12'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_vars_helper', '~> 0.1'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'simplecov', '0.17'
  spec.add_development_dependency 'simplecov-html', '~> 0.10.0'
end
