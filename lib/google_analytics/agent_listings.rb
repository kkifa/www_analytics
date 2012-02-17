module GoogleAnalytics
  class AgentListings
    extend Garb::Model
    dimensions :page_path, :date, :referral_path
    metrics  :pageviews, :unique_pageviews
  end
end
