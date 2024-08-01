#!/usr/bin/env ruby

require_relative './circle'
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

client = CircleClient.new
step_client = CircleClientV1.new
pipeline = client.latest_pipeline_for(branch: current_branch(argv))
workflow = client.latest_workflow_for(pipeline_id: pipeline['id'])
jobs = client.jobs_for(workflow_id: workflow['id'])
started_jobs = jobs.reject {|job| !job['started_at'] }.sort_by { |job| job['started_at'] }
steps_by_job = jobs.each_with_object({}) { |job, h| h[job['job_number']] = step_client.steps_for(job_number: job['job_number']) }

status_url = "https://app.circleci.com/pipelines/gh/#{PROJECT_SLUG}/#{pipeline['number']}/workflows/#{workflow['id']}"

def job_status_url_for(job)
  "https://circleci.com/gh/#{PROJECT_SLUG}/#{job['job_number']}"
end

if options[:open_status]
  $stderr.puts "Opening #{status_url} in a browser"
  `open "#{status_url}"`
  exit 0
end

if options[:open_failures]
  failure_urls = started_jobs.select { _1['status'] == 'failed' }.map(&method(:job_status_url_for))

  $stderr.puts "Opening #{failure_urls.size} failures in a browser"
  failure_urls.each { `open "#{_1}"` }
  exit 0
end


puts "%-25<name>s\t%10<status>s\t%-20<current_step>s\t%<url>s" % { name: 'Name', status: 'Status', current_step: 'CurrentStep', url: 'URL' }
started_jobs.each do |job|
  current_step = steps_by_job[job['job_number']].find {|step| step.dig('actions', 0, 'status') == 'running' && step['name'].downcase != 'task lifecycle' }
  current_step ||= { 'name' => 'Completed' }

  current_step['name'] = current_step['name'].size > 17 ? current_step['name'][0..15] + "..." : current_step['name']

  puts "%-25<name>s\t%10<status>s\t%-20<current_step>s\t%<url>s" % { name: job['name'], status: job['status'], current_step: current_step['name'], url: job_status_url_for(job) }
end
puts status_url
