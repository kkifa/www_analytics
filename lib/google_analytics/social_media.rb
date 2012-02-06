module GoogleAnalytics
  class SocialMedia
    extend Garb::Model
    dimensions  :referral_path, :source
    metrics  :pageviews, :unique_pageviews
  end
end
