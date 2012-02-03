module GoogleAnalytics
  class Test
    extend Garb::Model

    dimensions  :page_path_level_4, :referral_path, :source
    metrics  :pageviews, :unique_pageviews
  end
end
