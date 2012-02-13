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
    end
                                       
  end
  def agents   
    @stuff = {}
    @title = "Windermere analytics - agents"
    set_agent_params
    unless params[:profile].nil?
      @results = Ga.query(params[:profile])
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
end
