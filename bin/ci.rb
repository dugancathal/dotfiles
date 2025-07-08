#!/usr/bin/env ruby

require_relative '../rubylib/rubylib'
require 'ci'
require 'ci/circle'
require 'optparse'

options = {}
argv = OptionParser.new do |o|
  o.on('--open-failures', '-f', 'Open the CI runs that failed in new browser tabs') do
    options[:open_failures] = true
  end

  o.on('--open-status', '-o', 'Open the current state of the CI run in a new browser tab') do
    options[:open_status] = true
  end

  o.on('--help', '-h') do
    $stderr.puts 'Usage: ci.rb [options] [branch-name]'
    exit 1
  end
end.parse!

ci = Ci.client

jobs = ci.latest_jobs_for(branch: Ci.current_branch(argv))
status_url = ci.status_url_for(branch: Ci.current_branch(argv))

def truncate_name(name, max_length = 17)
  name.size > 17 ? "#{name[0..14]}..." : name
end

if options[:open_status]
  $stderr.puts "Opening #{status_url} in a browser"
  `open "#{status_url}"`
  exit 0
end

if options[:open_failures]
  failure_urls = jobs.map(&:url)

  $stderr.puts "Opening #{failure_urls.size} failures in a browser"
  failure_urls.each { `open "#{_1}"` }
  exit 0
end

ROW_FORMAT = "%-25<name>s\t%10<status>s\t%-20<current_step>s\t%<url>s" 
header_row_values = { name: 'Name', status: 'Status', current_step: 'CurrentStep', url: 'URL' }

puts ROW_FORMAT % header_row_values

jobs.each do |job|
  puts ROW_FORMAT % {
    name: truncate_name(job.name),
    status: job.status,
    current_step: truncate_name(job.current_step.name),
    url: job.url
  }
end

puts status_url
