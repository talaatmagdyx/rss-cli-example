#!/usr/bin/env ruby

require 'rss_feed'
require 'nokogiri'
require 'optparse'
require 'json'
require 'cgi'

# Method to display hash data with HTML entity decoding
def display_hash_data(hash, level = 0)
    hash.each do |key, value|
      if value.is_a?(Hash)
        puts "#{' ' * (level * 2)}#{key}:"
        display_hash_data(value, level + 1)
      elsif value.is_a?(Array)
        value.each_with_index do |item, index|
          puts "#{' ' * (level * 2)}#{key} #{index + 1}:"
          display_hash_data(item, level + 1)
          puts ' ' if index < value.length - 1
        end
      else
        decoded_value = CGI.unescapeHTML(value)
        puts "#{' ' * (level * 2)}#{key}: #{decoded_value}"
      end
    end
  end

# Define a method to parse command-line options
def parse_options
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

    opts.on("-uURL", "--url=URL", "URL of the RSS feed") do |url|
      options[:url] = url
    end

    opts.on("-tTIMEOUT", "--timeout=TIMEOUT", Integer, "Request timeout in seconds (default: 10)") do |timeout|
      options[:timeout] = timeout
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!

  unless options[:url]
    puts "Error: Please provide the URL of the RSS feed."
    exit 1
  end

  options[:timeout] ||= 10
  options
end

# Main execution starts here
options = parse_options

# Initialize the Parser class with custom options
parser = RssFeed::Parser.new(options[:url], timeout: options[:timeout], xml_parser: Nokogiri, uri_parser: URI)

# Parse the RSS feed as JSON
parsed_data = parser.parse 

display_hash_data(parsed_data)