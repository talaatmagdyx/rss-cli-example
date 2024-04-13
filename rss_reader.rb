#!/usr/bin/env ruby

require 'rss_feed'
require 'nokogiri'
require 'optparse'
require 'json'
require 'cgi'
require 'tty-markdown'

# Method to display hash data with HTML entity decoding
def display_hash_data(hash, level = 0)
  hash.each do |key, value|
    # Remove 'values' from the key if it exists at the end
    key = key.to_s.gsub(/: ?values$/, '')

    # Check the data type of the value
    if value.is_a?(Hash)
      # If the value is a hash, print the key and then recurse deeper
      puts "#{' ' * (level * 2)}#{key}:"
      display_hash_data(value, level + 1)
    elsif value.is_a?(Array)
      # If the value is an array, iterate through each item in the array
      value.each_with_index do |item, index|
        puts "#{' ' * (level * 2)}#{key} #{index + 1}:"
        display_hash_data(item, level + 1)
      end
    else
      # Decode the value
      decoded_value = CGI.unescapeHTML(value.to_s)

      # Check if the decoded value is HTML (using simple detection of "<" in the string)
      if decoded_value.include?("<")
        # If it contains HTML content, use display_html_content
        display_html_content(decoded_value)
      else
        # Otherwise, just print the key and decoded value
        puts "#{' ' * (level * 2)}#{key}: #{decoded_value}"
      end
    end
  end
end

# Method to display HTML content using Markdown format
def display_html_content(html_content)
  # Decode HTML entities
  decoded_html = CGI.unescapeHTML(html_content)
  # Convert HTML to Markdown using TTY::Markdown
  markdown_content = TTY::Markdown.parse(decoded_html)
  # Print the Markdown content
  puts markdown_content
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