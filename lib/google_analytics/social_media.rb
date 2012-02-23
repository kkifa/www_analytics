module GoogleAnalytics
  class SocialMedia
    extend Garb::Model
    dimensions  :page_path, :date, :campaign, :source, :previous_page_path, :latitude, :longitude
    metrics  :pageviews, :unique_pageviews
  end
end
