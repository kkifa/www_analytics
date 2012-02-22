module GoogleAnalytics
  class SocialMedia
    extend Garb::Model
    dimensions  :page_path, :date, :campaign, :source
    metrics  :pageviews, :unique_pageviews
  end
end
