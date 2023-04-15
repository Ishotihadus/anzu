# frozen_string_literal: true

require_relative 'lib/anzu/version'

Gem::Specification.new do |spec|
  spec.name = 'anzu'
  spec.version = Anzu::VERSION
  spec.authors = ['Ishotihadus']
  spec.email = ['hanachan.pao@gmail.com']

  spec.summary = 'Twitter API wrapper for Ruby'
  spec.description = 'Twitter API wrapper for Ruby'
  spec.homepage = 'https://github.com/Ishotihadus/anzu'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'mime-types'
  spec.add_dependency 'simple_oauth'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
