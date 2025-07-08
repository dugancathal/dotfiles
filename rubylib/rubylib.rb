$LOAD_PATH << File.expand_path('.', __dir__)

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'httparty', require: true
end

module DotfilesHome
end
