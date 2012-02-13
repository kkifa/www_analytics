class Ga < ActiveRecord::Base
  require 'rubygems'
  require 'garb'
  USER = Rails.application.config.analytics_login[:user]
  PASSWORD = Rails.application.config.analytics_login[:password]
  Garb::Session.login(USER, PASSWORD)
  def self.query(params = nil) 
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    if params[:agent]
      GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile,
                                                                         :filters => get_agent_listings(params[:agent]),
                                                                         :end_date => Date.today,
                                                                         :start_date => Date.parse(params[:start_date])
                                                                        )
    else
      GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile, 
                                                                         :filters =>  get_office_listings(params[:office]),
                                                                         :end_date => Date.today,
                                                                         :start_date => Date.parse(params[:start_date])
                                                                        )
    end

  end

  def self.test()
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    GoogleAnalytics.const_get("AgentListings").results(profile, 
                                      :filters =>  get_office_listings(8147730),
                                      :end_date => Date.today,
                                      :start_date => 1.month.ago.to_date
                                      )
  end


end

def param_to_class(report)
  report.split.collect {|x| x.capitalize}.join
end

def listings_to_filters(listing_ids)
  filters = []
  for listing_id in listing_ids
    # filters << {:page_path.contains => listing_id, :page_path.contains => "\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?"}
    filters << {:page_path.contains => listing_id}
  end
  return filters
end

def get_agent_listings(agent_id)
  listings = WmsSvcConsumer::Models::Listing.find_all_by_agent(agent_id).results.map {|listing| listing.listingid}
  listings_to_filters(listings)
end

def get_office_listings(office_id)
  listings = WmsSvcConsumer::Models::Listing.find_all_by_office(office_id).results.map {|listing| listing.listingid}
  listings_to_filters(listings)
end

def date_range()
end

module Fields
  def fields
    @table.keys
  end
end
class OpenStruct
  include Fields
end 
