#!/usr/bin/env ruby
require 'date'
require 'httparty'
require 'nokogiri'
require 'tzinfo'

def generate_headers
  base_response = HTTParty.get('https://everytimezone.com')
  html = Nokogiri::HTML(base_response.body)
  csrf_token = html.css('meta[name="csrf-token"]').first[:content]
  cookie = base_response.headers['set-cookie']

  {
    'X-CSRF-Token' => csrf_token,
    'Cookie' => cookie,
  }
end

timeish = ARGV[0]
match = timeish.match(/(?<hours>\d?\d)(?<minutes>\d\d)/)

ref_date = Date.today
time = Time.new(ref_date.year, ref_date.month, ref_date.day, match[:hours], match[:minutes], 0, TZInfo::Timezone.get('America/Denver'))

response = HTTParty.post('https://everytimezone.com/zones/get_link.js',
  body: {
    ref_date: ref_date,
    time: time.utc.iso8601,
  },
  headers: generate_headers
)

link_match = response.body.match(%r{https://everytimezone.com/s/\w+})

puts "[#{timeish}](#{link_match})"

