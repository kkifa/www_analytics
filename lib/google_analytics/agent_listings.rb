module GoogleAnalytics
  class AgentListings
    extend Garb::Model

    metrics  :pageviews, :unique_pageviews
    dimensions :page_path, :medium, :referral_path, :second_page_path
  end
end
