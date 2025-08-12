#!/usr/bin/env ruby

require 'nokogiri'

Failure = Struct.new(:classname, :testname, :failure_message, :output, keyword_init: true) do
  def fully_qualified_name = [classname, testname].join('.')
end

FAILURE_XML_GLOB = '**/*.testsresults.xml'

failures = Dir[FAILURE_XML_GLOB].flat_map do |result_file|
  doc = Nokogiri::XML(File.read(result_file))
  failed_cases = doc.css("testcase:has(> failure)")
  failed_cases.map do |failed_case|
    failure = failed_case.first_element_child
    Failure.new(
      classname: failed_case['classname'],
      testname: failed_case['name'],
      failure_message: failure['message'],
      output: failure.text
    )
  end
end

messages = failures.map do |failure|
  <<~FAIL
    Failure: #{failure.fully_qualified_name}
    Message:
      #{failure.failure_message}

    Output:

      #{failure.output}
  FAIL
end

puts messages.join("\n========================================================\n")
