class Ga < ActiveRecord::Base

  require 'rubygems'
  require 'garb'
  USER = Rails.application.config.analytics_login[:user]
  PASSWORD = Rails.application.config.analytics_login[:password]
  Garb::Session.login(USER, PASSWORD)
  
  def self.query(params = nil) 
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    # profile = Garb::Profile.all.last
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
    # GoogleAnalytics::Test.results(profile, :filters => {:page_path.eql => '/', :medium.contains => "facebook"})
    # GoogleAnalytics::AgentListings.results(profile, :limit => 10, :filters => [{:page_path.contains => "\/\d{7,}(\?refer=map)?$"}, {:page_path.contains => "^\/listing(s)?"} ])
    # GoogleAnalytics::AgentListings.results(profile, :limit => 10, :filters => [{:page_path.contains => "\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?"}])
    if params[:report] == "test"
      GoogleAnalytics::Test.results(profile, :sort => :unique_pageviews.desc, :limit => 100, :filters => [{:page_path.contains => "\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?"}])
    end
    # GoogleAnalytics::AgentListings.results(profile, :filters => {:page_path.contains => ""})
    # Test.results(profile)
  end

  def self.profiles
    profiles = Garb::Profile.all
    profiles_list = []
    profiles.each {|p| profiles_list.push [p.table_id,  p.title + ' (' + p.account_name.upcase + ')' ] }
    profiles = profiles_list.sort_by {|k,v| v }
  end

  def self.start_date(params = nil)
    start_date = Date.civil(params[:"start_date(1i)"].to_i,params[:"start_date(2i)"].to_i,params[:"start_date(3i)"].to_i)
  end

  def self.end_date(params = nil)
    end_date = Date.civil(params[:"end_date(1i)"].to_i,params[:"end_date(2i)"].to_i,params[:"end_date(3i)"].to_i)
  end
end
module Fields
  def fields
    @table.keys
  end
end
class OpenStruct
  include Fields
end 
