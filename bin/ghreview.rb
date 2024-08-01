#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'tempfile'

CHECKBOX_REGEX = /\[ \] (.*)$/.freeze

def for_each_checkbox(lines, after_header:, &block)
  return to_enum(:for_each_checkbox, lines, after_header: after_header) unless block_given?

  header_index = lines.index { Regexp.new(after_header).match(_1) }

  next_header_index = lines.index.with_index { |line, index| index > header_index && line.start_with?('#') }
  next_header_index ||= -1

  lines[header_index..next_header_index].each do |line|
    match = line.match(CHECKBOX_REGEX)
    next unless match && match[1] 

    block.call line
  end
end

def check_checkboxes(text, after_header:)
  lines = text.lines

  for_each_checkbox(lines, after_header: after_header) do |line|
    line.sub!(/\[ \]/, '[x]')
  end

  lines.join
end

def main
  pr_number = ARGV[0]
  app_path = Pathname(ARGV[1])

  Dir.chdir(File.expand_path(app_path)) do
    raw_pr_body = `gh pr view --json body #{pr_number}`
    pr_body = JSON.parse(raw_pr_body)['body']

    reviewed_pr_body = check_checkboxes(pr_body, after_header: /Reviewer\/Approval Done List/)

    Tempfile.create do |f|
      f.puts(reviewed_pr_body)
      f.flush

      `gh pr edit #{pr_number} --body-file #{f.path}`
    end
  end
end

require 'rspec'

if ARGV.include?('--test')
  ARGV.delete('--test')
  require 'rspec/autorun'
else
  main
end

RSpec.describe 'updating the description' do
  it 'extracts checkboxes from the content' do
    text = <<~MD
      [ ] a checkbox
      [ ] another checkbox
    MD

    expect(for_each_checkbox(text.lines, after_header: '').to_a).to match_array ["[ ] a checkbox\n", "[ ] another checkbox\n"]
  end

  it 'extracts checkboxes after a specified line' do
    text = <<~MD
      [ ] I should be ignored
      # Match on me
      [ ] I should be matched
    MD

    expect(for_each_checkbox(text.lines, after_header: /Match on me/).to_a).to match_array ["[ ] I should be matched\n"]
  end

  it 'extracts checkboxes after a specified line until the next HEADER' do
    text = <<~MD
      [ ] I should be ignored
      # Match on me
      [ ] I should be matched
      # Stop here
      [ ] I should also be ignored
    MD

    expect(for_each_checkbox(text.lines, after_header: /Match on me/).to_a).to match_array ["[ ] I should be matched\n"]
  end

  it 'checks the checkboxes between headers' do
    text = <<~MD
      [ ] I should be ignored
      # Match on me
      [ ] I should be matched
      # Stop here
      [ ] I should also be ignored
    MD

    expect(check_checkboxes(text, after_header: /Match on me/)).to eq <<~MD
      [ ] I should be ignored
      # Match on me
      [x] I should be matched
      # Stop here
      [ ] I should also be ignored
    MD
  end
end
