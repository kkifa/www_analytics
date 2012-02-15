class GaController < ApplicationController # before_filter :profiles_list

  def report   
    @stuff = {}
    @title = "Windermere analytics test report"
    unless params[:report].nil?
      if !params[:report][:listing].empty?
        @listings = WmsSvcConsumer::Models::Listing.find(listing_snipe(params[:report][:listing]))
      else
        @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])
      end
      @results = listings_only_filter(params[:report])
      @listing_page_visits = Array.new
      @columns = @results.first.fields
      @listings.results.each { |listing|
        @date_visits = Hash.new(0)
        unique_visits = 0
        total_visits = 0
        @results.each{ |result|
          if result.send(@columns[0]).include? listing.listingid.to_s
            unique_visits += result.send(@columns[3]).to_i
            total_visits += result.send(@columns[2]).to_i

            visits = @date_visits[result.send(@columns[1])]
            if visits == 0
              visits = Array.new
              visits[0] = result.send(@columns[2]).to_i # pageviews
              visits[1] = result.send(@columns[3]).to_i # unique
            else
              visits[0] += result.send(@columns[2]).to_i # pageviews
              visits[1] += result.send(@columns[3]).to_i # unique
            end
            @date_visits[result.send(@columns[1])] = visits

          end
        }

        #puts listing.listingid
        #puts Hash[@date_visits.sort]
        #puts " "
        @listing_page_visits << [listing.listingid, Hash[@date_visits.sort]]
      }

      #puts @listing_page_visits

      if @results.count == 0
        redirect_to "ga/empty"
        gflash :warning => "Found zero results for the given search criteria."
      else
        @columns = @results.first.fields
        @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])
        gflash  :success => {:value =>  "OOOHHH YEAH!!!! koolaid!!", :image => "/assets/koolaid-small.png"}
      end
      @columns = @results.first.fields

    end
  end

  def empty
    @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])
  end
  
  def agents   
    @stuff = {}
    @title = "Windermere analytics - agents"
    set_agent_params
    unless params[:profile].nil?
      @results = listings_only_filter(params[:profile])
      @stuff = params[:profile]
      @start_date = Ga.start_date(params[:profile])
      @end_date = Ga.end_date(params[:profile])
    render "ga/show"
    end
  end

  def profiles_list
    @profiles = Ga.profiles
  end
  def set_agent_params
    params[:profile] = {
    profile_id: "ga:605724",
    :"start_date(1i)" =>  2011,
    :"start_date(2i)" =>  12,
    :"start_date(3i)" =>  27,
    :"end_date(1i)" =>  2012,
    :"end_date(2i)" =>  1,
    :"end_date(3i)" =>  27, 
    dimensions: [ 'secondPagePath' ],
    metrics: ['pageviews', 'uniquePageviews'],
    limit: 50,
    sort: "asc"
    }
  end
  private
  def listings_only_filter(report)
    results = Ga.query(report)
    results.class.instance_eval('attr_accessor :uuid, :date_dimension')
    filtered_results = []
    results.each do |result|
      filtered_results << result if result.send(:page_path).match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    end
    aggregated_listings(report, filtered_results)
  end
  def aggregated_listings(report, filtered_results)
    listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(report["agent"])
    listings_ids = []
    for listing in listings.results.each
      listings_ids << listing.listingid
    end
    listings_ids.each do |id|
      filtered_results.each do |result|
        if result.send(:page_path).match(/#{id}/)
          result.uuid = id 
        end
      end
    end
    set_dates(filtered_results)
    return filtered_results
  end

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

  def listing_snipe(listing_url)
    snipe = listing_url.match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    if snipe
      listing = [8067751]
    end
    return listing
  end
end

