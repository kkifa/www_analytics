class Report < Garb::ResultSet
  require 'rubygems'
  require 'wms_svc_consumer'
  require 'date'
  attr_accessor :uuid, :date_dimension, :agent, :office, :columns, :listings, :listing, :results, :report, :start_date
  USER = Rails.application.config.analytics_login[:user]
  PASSWORD = Rails.application.config.analytics_login[:password]
  Garb::Session.login(USER, PASSWORD)
  def initialize(params)
    puts params
    # args.each {|k,v| instance_variable_set("@#{k}", v)}
    query(params)
    super(@results)
  end

  def query(params)
    profile =  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    # if !params["report"].blank?
    if params[:listingid]
      @listings = Listing.find(params[:listingid])
      # @listing = WmsSvcConsumer::Models::Listing.find(snipe_listing_from_url(params["listing"]))
      @agent = @listings.agent
      @results = GoogleAnalytics.const_get(param_to_class('social media')).results(profile,
                                                                         # :filters => listings_to_filters(@listing ),
                                                                         :filters => {:page_path.contains => @listings.listingid},
                                                                         :end_date => Date.today,
                                                                         # :start_date => Date.parse(params["start_date"])
                                                                         :start_date => 1.month.ago
                                                                        )
      begin
        @columns = arrange_columns( @results.first.fields )
      rescue NoMethodError
        puts "there was no value returned by analytics"
        @columns = [:page_path, :date, :pageviews, :unique_pageviews]
      end
    elsif params["agent"]
      @agent = Agent.find(params["agent"])
      @listings = Listing.find_all_by_agent(@agent.uuid).results
      @listingsids = @listings.map(&:listingid)
      @results = filtered_results(GoogleAnalytics.const_get(param_to_class(params["report"])).results(profile,
                                                                         :filters => listings_to_filters(@listingsids),
                                                                         :end_date => Date.today,
                                                                         :start_date => Date.parse(params["start_date"])
                                                                        )
                                  )
      begin
        @columns = arrange_columns( @results.first.fields )
      rescue NoMethodError
        puts "there was no value returned by analytics"
        @columns = [:page_path, :date, :pageviews, :unique_pageviews]
      end
    elsif params["report"]
      @results = googleanalytics.const_get(param_to_class(params["report"])).results(profile, 
                                                                         :filters =>  get_office_listings(params["office"]),
                                                                         :end_date => date.today,
                                                                         :start_date => date.parse(params[:start_date])
                                                                        )
    #there is an opportunity to sort the columns below
      begin
        @columns = arrange_columns(@results.first.fields)
      rescue NoMethodError
        @columns = [:page_path, :date, :pageviews, :unique_pageviews]
      end
    end
  end

  def test
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    # @listing = self.snipe_listing_from_url('http://www.windermere.com/listing/WA/Kirkland/13245-Holmes-Point-Dr-Ne-98034/10872720')
    # @listing = listings_to_filters('10872720')
    GoogleAnalytics.const_get("AgentListings").results(profile, 
                                      :filters => listings_to_filters(11736186),
                                      :end_date => ::Date.today,
                                      :start_date => 1.month.ago.to_date
                                      )
  end
  
  def listings_to_filters(listing_ids)
    filters = []
    if listing_ids.kind_of?(Array)
      for listing_id in listing_ids
        filters << {:page_path.contains => listing_id}
      end
    else
      filters = {:page_path.contains => listing_ids}
    end
    return filters
  end

  def filtered_results(results)
    filtered_results = []
    results.each do |result|
      filtered_results << result if result.send(:page_path).match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    end
    assign_uuid_to_result(filtered_results)
  end

  #assigns uuid to results
  def assign_uuid_to_result(filtered_results)
    filtered_results.class.instance_eval('attr_accessor :uuid, :date_dimension')
    @listingsids.each do |id|
      filtered_results.each do |listing|
        if listing.send(:page_path).match(/#{id}/)
          listing.uuid = id
        end
      end
    end
    return filtered_results
  end

  #grab the listing id from url string
  def snipe_listing_from_url(listing_url)
    snipe = listing_url.match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    if snipe
      result1, result2, result3 = snipe[1], snipe[2], snipe[3]
      if result1
        listing = result1.sub("/","")
      elsif result2
        listing = result2
      elsif result3
        listing = result3
      end
    end
  end

  def get_agent(agent)
    @agent ||= wmssvcconsumer::models::agent.find(agent)
  end

  def param_to_class(report)
    report.split.collect {|x| x.capitalize}.join
  end

  def arrange_columns(fields)
    #these values need to be in every Garb::Model report.
    sorting_arrangement_key = [:page_path, :date, :pageviews, :unique_pageviews]
    # remove the neccessary dimensions and metrics then push them back into the front of array
    extra_fields = fields - sorting_arrangement_key
    sorting_arrangement_key.each_with_index do |sym, index|
      extra_fields.insert(index, sym)
    end
    return extra_fields
  end
  
  #does the same thing as aggregate_listings in controller but as a hash object
  def set_dates(results)
    @date_dimension = []
    for result in results
      stored_element = @date_dimension.detect { |element| element[:date].to_s == result.send(:date).to_s }
      if stored_element
        stored_element[:value][:pageviews] += result.send(:pageviews).to_i
        stored_element[:value][:unique_pageviews] += result.send(:unique_pageviews).to_i
      else
        @date_dimension << {:date => result.send(:date).to_s, :value => {:pageviews => result.send(:pageviews).to_i, :unique_pageviews => result.send(:unique_pageviews).to_i} }
      end
      result.date_dimension = @date_dimension
    end
  end

end

