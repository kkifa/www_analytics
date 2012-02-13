class GaController < ApplicationController

  # before_filter :profiles_list

  def report   
    @stuff = {}
    @title = "Windermere analytics test report"
    unless params[:report].nil?

      @results = Ga.query(params[:report])
      @columns = @results.first.fields
      @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])

      @listing_page_visits = Array.new

      @listings.results.each { |listing|
        unique_visits = 0
        total_visits = 0
        @results.each{ |result|
          if result.send(@columns[0]).include? listing.listingid.to_s
            unique_visits = unique_visits + result.send(@columns[2]).to_i
            total_visits = total_visits + result.send(@columns[1]).to_i
          end
        }

        @listing_page_visits << [listing.listingid, unique_visits, total_visits]

      }

      # @results = Ga.query(params[:report])
      @results = listings_only_filter(params[:report])
      if @results.empty?
        redirect_to "ga/empty", :notice => "Found zero results for the given search criteria. D: "
        gflash :warning => "Found zero results for the given search criteria. D: ", :notice => "testing this shit"
      else
        @columns = @results.first.fields
        @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])
        gflash  :success => "OOOHHH YEAH!!!! Here is this shit you wanted"
      end

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
    results.class.instance_eval('attr_accessor :uuid')
    filtered_results = []
    results.each do |result|
      filtered_results << result if result.send(:page_path).match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
      # filtered_results << result if result.send(:page_path).match(/\/listing(\/[\w\-]+){4}|\/listings/)
    end
    # return filtered_results.compact!
    # return filtered_results
    aggregated_listings(report, filtered_results)
  end
  def aggregated_listings(report, filtered_results)
    listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(report["agent"])
    listings_ids = []
    for listing in listings.results.each
      listings_ids << listing.listingid
    end
    listings_ids.each do |id|
      filtered_results.each do |listing|
        if listing.send(:page_path).match(/#{id}/)
          listing.uuid = id 
        end
      end
    end
    return filtered_results
  end
end

