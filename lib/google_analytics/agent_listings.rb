module GoogleAnalytics
  class AgentListings
    extend Garb::Model
    metrics  :pageviews, :unique_pageviews
    dimensions :page_path
  end
end
