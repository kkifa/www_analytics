class Ga < ActiveRecord::Base
  require 'rubygems'
  require 'garb'
  USER = Rails.application.config.analytics_login[:user]
  PASSWORD = Rails.application.config.analytics_login[:password]
  Garb::Session.login(USER, PASSWORD)
  
  def self.query(params = nil) 
    # profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    # profile = Garb::Management::Profile.all.first
    # report = Garb::Report.new(profile, 
    #                           :start_date => start_date(params), 
    #                           :end_date => end_date(params), 
    #                           :limit => params[:limit].to_s, 
    #                           :offset => params[:offset].to_s
    #                           )
    # report.metrics params[:metrics]
    # report.dimensions params[:dimensions]
    # if params[:sort] == 'desc'
    #   sort =  params[:metrics].first
    #   report.sort sort.to_sym.desc
    # end
    # report.results()

    # GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile ,  :filters =>  [{:page_path.contains => '9779425'},{ :page_path.contains => "10277928"}]) #, :sort => :unique_pageviews.desc, :limit => 10)
    GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile,  :filters => filter_by_agent_listing(["10277928", "10191776", "9779425"]) )
    # GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile, :filters =>  { :page_path.contains => "9779425"} )
    # GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile)#, :filters =>  { :page_path.contains => "10277928"} )
  end

  # def self.profiles
  #   profiles = Garb::Management::Profile.all
  #   profiles_list = []
  #   profiles.each {|p| profiles_list.push [p.table_id,  p.title + ' (' + p.account_name.upcase + ')' ] }
  #   profiles = profiles_list.sort_by {|k,v| v }
  # end

  def self.start_date(params = nil)
    start_date = Date.civil(params[:"start_date(1i)"].to_i,params[:"start_date(2i)"].to_i,params[:"start_date(3i)"].to_i)
  end

  def self.end_date(params = nil)
    end_date = Date.civil(params[:"end_date(1i)"].to_i,params[:"end_date(2i)"].to_i,params[:"end_date(3i)"].to_i)
  end
end
private

def param_to_class(report)
  report.split.collect {|x| x.capitalize}.join
end

def filter_by_agent_listing(listing_ids)
  filters = []
  for listing_id in listing_ids
    # filters << {:page_path.contains => listing_id, :page_path.contains => "\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?"}
    filters << {:page_path.contains => listing_id}
  end
  return filters
end

module Fields
  def fields
    @table.keys
  end
end
class OpenStruct
  include Fields
end 
