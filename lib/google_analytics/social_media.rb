module GoogleAnalytics
  class SocialMedia
    extend Garb::Model
    dimensions  :page_path, :date, :social_source
    metrics  :pageviews, :unique_pageviews
  end
end
