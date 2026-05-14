# frozen_string_literal: true

require "rss/maker"
require "time"

class Journal
  class RssFeed
    def initialize(journal:, entries:, feed_url:, entry_url:)
      @journal = journal
      @entries = entries
      @feed_url = feed_url
      @entry_url = entry_url
    end

    def to_xml
      RSS::Maker.make("2.0") do |feed|
        feed.channel.title = title
        feed.channel.link = feed_url
        feed.channel.description = description

        entries.each do |entry|
          feed.items.new_item do |item|
            item.title = entry.headline
            item.link = entry_url.call(entry)
            item.description = entry_description(entry)
            item.pubDate = rss_time(entry.published_at || entry.updated_at)
            item.guid.content = item.link
            item.guid.isPermaLink = true
          end
        end
      end.to_s
    end

    private

    attr_reader :journal, :entries, :feed_url, :entry_url

    def title
      "#{journal.room.name} Journal"
    end

    def description
      "Recent entries from #{journal.room.name}"
    end

    def entry_description(entry)
      entry.summary.to_s.empty? ? entry.body : entry.summary
    end

    def rss_time(value)
      value&.to_time
    end
  end
end
