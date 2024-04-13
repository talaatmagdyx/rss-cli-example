#!/usr/bin/env ruby

require 'rss_feed'
require 'nokogiri'
require 'optparse'
require 'json'
require 'cgi'
require 'tty-markdown'

# Method to display hash data with HTML entity decoding
# Method to display hash data with HTML entity decoding and bold keys
def display_hash_data(hash, level = 0)
  hash.each do |key, value|
    # Format the key as bold using ANSI escape sequences
    bold_key = "\e[1m#{key}\e[0m"

    # Check the data type of the value
    if value.is_a?(Hash)
      # If the value is a hash, print the bold key and then recurse deeper
      puts "#{' ' * (level * 2)}#{bold_key}:"
      display_hash_data(value, level + 1)
    elsif value.is_a?(Array)
      # If the value is an array, iterate through each item in the array
      value.each_with_index do |item, index|
        puts "#{' ' * (level * 2)}#{bold_key} #{index + 1}:"
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
        # Print the bold key and decoded value
        puts "#{' ' * (level * 2)}#{bold_key}: #{decoded_value}"
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

# Display the list of RSS feed items in a table format and prompt user for selection
def display_rss_feed_list(rss_data)
  # Ensure there are items in the RSS feed data
  if rss_data["items"].is_a?(Array)
    # Calculate maximum lengths for each column
    max_index_length = rss_data["items"].size.to_s.length
    max_title_length = rss_data["items"].map { |item| item["title"]["values"].length }.max
    max_url_length = rss_data["items"].map { |item| item["link"]["values"].length }.max
    max_pub_date_length = rss_data["items"].map { |item| item["pubDate"]["values"].length }.max

    # Format the header with the calculated column lengths
    header = format("%-#{max_index_length}s | %-#{max_title_length}s | %-#{max_url_length}s | %-#{max_pub_date_length}s",
                    "idx", "title", "url", "pubDate")
    puts header
    puts "-" * header.length

    # Display a list of items in a table format with consistent padding
    rss_data["items"].each_with_index do |item, index|
      # Access the attributes from the item hash
      title = item["title"]["values"]
      url = item["link"]["values"]
      pub_date = item["pubDate"]["values"]

      # Format and print the item in the desired format
      puts format("%-#{max_index_length}d | %-#{max_title_length}s | %-#{max_url_length}s | %-#{max_pub_date_length}s",
                  index + 1, title, url, pub_date)
    end

    loop do
      # Prompt user to choose an item by number
      print "Choose an item to view its contents (enter the number) or type 'q' to quit: "
      choice = gets.chomp

      if choice.downcase == 'q'
        puts "Exiting the application."
        break
      end

      chosen_index = choice.to_i - 1

      # Validate the chosen index
      if chosen_index >= 0 && chosen_index < rss_data["items"].length
        # Display the details of the chosen item
        chosen_item = rss_data["items"][chosen_index]
        display_hash_data(chosen_item)

        # Ask the user if they want to read another item or close the app
        print "Would you like to view another item? (y/n): "
        answer = gets.chomp.downcase

        if answer == 'n'
          puts "Exiting the application."
          break
        end
      else
        puts "Invalid choice. Please enter a valid number or 'q' to quit."
      end
    end
  else
    puts "No items found in the RSS feed."
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

# Display the list of RSS feed items and prompt user for selection
display_rss_feed_list(parsed_data)
