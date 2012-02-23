module GoogleAnalytics
  class AgentListing
    extend Garb::Model
    dimensions :page_path, :date
    metrics  :pageviews, :unique_pageviews
  end
end
