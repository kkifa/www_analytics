module GoogleAnalytics
  class Test
    extend Garb::Model

    metrics :exits, :pageviews, :unique_pageviews
    dimensions :page_path, :medium, :referral_path, :second_page_path
  end
end
