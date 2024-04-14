# RSS Feed Reader Application

This is a Ruby application that allows you to read and interact with RSS feeds. It uses the Nokogiri and tty-markdown gems to parse RSS feeds and display them in a user-friendly format. You can select a specific RSS feed item to view its contents in detail.

## Features

- Retrieve and parse RSS feeds from a specified URL.
- Display a list of RSS feed items in a table format with consistent padding.
- Choose a specific RSS feed item to view its contents.
- Display keys in bold when viewing a single article.
- Optionally read another item or close the application after viewing a single article.

## Requirements

- Ruby 2.6 or later
- [rss_feed_plus](https://github.com/talaatmagdyx/rss_feed_plus)

## Installation

1. Clone this repository:

    ```shell
    git clone https://github.com/talaatmagdyx/rss-cli-example.git
    cd rss-cli-example
    ```

2. Install the required Ruby gems:

    ```shell
    bundle install
    ```
3. Watch the animated GIF to see how the application works:
   ![RSS Feed Reader Usage](rss-feed-reader.gif)


## Usage

1. Run the application and provide the URL of the RSS feed as an argument:

```shell
./rss_reader.rb -u <rss-feed-url>
```

- Replace `<rss-feed-url>` with the URL of the RSS feed you want to read.

2. The application will display a list of RSS feed items in a table format. Choose an item by entering its corresponding number.

3. The application will display the contents of the chosen RSS feed item. The keys will be displayed in bold.

4. After viewing a single article, the application will prompt you to read another item or close the application.

## Examples

- Example command to run the application with an RSS feed URL:

    ```shell
    ./rss_reader.rb -u https://www.ruby-lang.org/en/feeds/news.rss
    ```

## License

This project is licensed under the MIT License. See the [MIT License](https://opensource.org/licenses/MIT) file for details.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.
