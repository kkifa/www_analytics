class GaController < ApplicationController # before_filter :profiles_list

  def report   
    @title = "Windermere analytics test report"
    unless params[:report].nil?
      if !params[:report]['listing'].blank?
        redirect_to listing_path(:listingid => listing_snipe(params[:report][:listing]))
        return 
      else
      @report = Report.new(params[:report])
      @results = @report.results
      @agent   = @report.agent
      @listings = @report.listings

      if @results.count == 0
        redirect_to reports_path
        gflash :warning => "Found zero results for the given search criteria."
      else
        aggregate_listings
        #gflash  :success => {:value =>  "OOOHHH YEAH!!!! Listing report for #{@agent.display_name}", :image => @agent.image.first["thumb_url"]}
      end
      #@columns = @results.first.fields
      end
    end
  end

  def empty
    @listings = Listing.find_all_by_agent(params[:report][:agent])
  end
  
  def listing
    @title   = "Windermere analytics test report"
    # @results = Report.new(params[:report])
    @report = Report.new(params)
    @results = @report.results
    @listing = @report.listings.first
    @agent   = @report.agent
    @columns = @report.columns
    @visitor_map = @report.results.map{|x| [x.latitude, x.longitude]}
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

  private


  def listing_snipe(listing_url)
    snipe = listing_url.match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    if snipe
      result1, result2, result3 = snipe[1], snipe[2], snipe[3]
      if result1
        listingid = result1.sub("/","")
      elsif result2
        listingid = result2
      elsif result3
        listingid = result3
      end
    end
      
  end
  def aggregate_listings
    @listing_page_visits = Array.new
    @columns = @report.columns
    @listings.each { |listing|
      @date_visits = Hash.new(0)
      @results.each{ |result|
        if result.send(@columns[0]).include? listing.listingid.to_s
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
  end
end

