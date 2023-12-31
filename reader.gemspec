# frozen_string_literal: true

require_relative "lib/reader/version"

Gem::Specification.new do |spec|
  spec.name = "reader"
  spec.version = Reader::VERSION
  spec.authors = ["Load A"]
  spec.email = ["143745153+load-a@users.noreply.github.com"]

  spec.summary = "This gem truns directory files into text arrays."
  spec.description = "The InDir object is initiated with a path and extension. It will then scan the directory path for all files with the extension and provide them as OutText objects. These objects can then be used or altered as the user needs."
  spec.homepage = "https://github.com/load-a/reader/tree/main"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  #spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/load-a/reader/tree/main"
  spec.metadata["changelog_uri"] = "https://github.com/load-a/reader/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
