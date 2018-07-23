#!/usr/bin/env ruby
require 'nokogiri'
require 'uri'

#
# This script will output search results for exercism.io in a 
# markdown format - run `ruby search.rb >> README.md` to
# append the results to the README.md file
#

# Ignore certain hosts and paths
ignore_regex = []
ignore_list = <<-EOS
*.exercism.io/*
*//exercism.io/*
https://twitter.com/exercism_io
https://twitter.com/exercism_io/*
https://www.facebook.com/exercism.io/*
https://github.com/exercism
https://github.com/exercism/*
EOS
.each_line do |line_unescaped|
    line = Regexp::escape(line_unescaped.strip)
    if line.length > 1 and line[0] == '\\' and line[1] == '*'
        line[0] = '.'
    end
    if line.length > 2 and line[-2] == '\\' and line[-1] == '*'
        line[-2] = '.'
    end
    ignore_regex << Regexp::new('^' + line + '$')
end
ignore_regex = Regexp::union(ignore_regex)

# Collect search results
search_results = %x(curl -s https://duckduckgo.com/html\?q\=%22exercism.io%22)

# Parse search results
doc = Nokogiri::HTML(search_results)
doc.css('.serp__results .results .result').each do |result|
    result_title = result.css('.result__title').text.strip

    result_url_link = result.css('.result__title a').attr('href').text.strip
    url_match = /uddg=([^\&]+)/.match(result_url_link)
    result_url = url_match ? URI.unescape(url_match[1]) : 'https://duckduckgo.com' + result_url_link
    result_host = /\/\/([^\/]+)\//.match(result_url)[1]

    next unless not ignore_regex.match(result_url)

    puts "- #{result_title} on [#{result_host}](#{result_url})"
end
