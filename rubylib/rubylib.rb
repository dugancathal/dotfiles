$LOAD_PATH << File.expand_path('.', __dir__)

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'httparty', require: true
end

module DotfilesHome
end
