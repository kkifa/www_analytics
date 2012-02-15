module GoogleAnalytics
  class Test
    extend Garb::Model
    dimensions :page_path, :date
    metrics  :pageviews, :unique_pageviews
  end
end
