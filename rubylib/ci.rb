require 'ci/ci_client'

module Ci
  def self.client = CircleClient.new

  def self.current_branch(argv = ARGV)
    argv.first || `git symbolic-ref HEAD`.strip.split('refs/heads/').last
  end
end
