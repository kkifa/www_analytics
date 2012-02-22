class GaController < ApplicationController # before_filter :profiles_list

  def report   
    @title = "Windermere analytics test report"
    unless params[:report].nil?
      if !params[:report]['listing'].blank?
        redirect_to reports_listing_path(params)
        return 
      else
      @report = Report.new(params[:report])
      @results = @report.results
      @agent   = @report.agent
      @listings = @report.listings

      if @results.count == 0
        render :nothing => true
        gflash :warning => "Found zero results for the given search criteria."
      else
        @listing_page_visits = Array.new
        @columns = @report.columns
        @listings.each { |listing|
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
                visits[0] = 0
                visits[1] = 0
                visits[2] = 0
              end

              if result.send(@columns[0]).include? "refer=map"
                visits[0] += result.send(@columns[2]).to_i # pageviews
              elsif result.send(@columns[0]).include? "/gallery"
                visits[1] += result.send(@columns[2]).to_i
              else
                visits[2] += result.send(@columns[2]).to_i
              end

              @date_visits[result.send(@columns[1])] = visits

            end
          }

          #puts Hash[@date_visits.sort]
          @listing_page_visits << [listing.listingid, Hash[@date_visits.sort]]
        }

        @columns = @report.columns
        gflash  :success => {:value =>  "OOOHHH YEAH!!!! Listing report for #{@agent.display_name}", :image => @agent.image.first["thumb_url"]}
      end
      #@columns = @results.first.fields
      end
    end
  end

  def empty
    @listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(params[:report][:agent])
  end
  
  def listing
    @title   = "Windermere analytics test report"
    # @results = Report.new(params[:report])
    @report = Report.new(params)
    @results = @report.results
    @listing = @report.listing
    @agent   = @report.agent
    @columns = @report.columns
    gflash  :success => {:value =>  "OOOHHH YEAH!!!! Listing report for #{@listing.location.address}", :image => @listing.images.first["thumb_url"]}
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

end

