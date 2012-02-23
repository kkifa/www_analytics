module GaHelper

  def dimensions_list
    dimensions_list = [
                        ['Visitor', ['browser', 'browserVersion', 'city', 'connectionSpeed', 'continent', 'country', 'date', 'day', 'daysSinceLastVisit',
                                      'flashVersion', 'hostname', 'hour', 'javaEnabled', 'language', 'latitude', 'longitude', 'month', 'networkDomain',
                                    'networkLocation', 'pageDepth', 'operatingSystem', 'operatingSystemVersion', 'region', 'screenColors', 'screenResolution',
                                  'subContinent', 'userDefinedValue', 'visitCount', 'visitLength', 'visitorType', 'week', 'year']],
                        ['Content', ['exitPagePath', 'landingPagePath', 'pagePath', 'pageTitle', 'secondPagePath']],
                        ['Internal', ['searchKeyword']],
                        ['Nav', ['nextPagePath', 'previousPagePath']],
                        ['Campaign', ['campaign','keyword', 'medium', 'referralPath', 'source']]
                      ]  
  end
  
  def metrics_list
    metrics_list = [
                    ['Visitor', ['bounces', 'entrances', 'exits', 'newVisits', 'pageviews', 'timeOnPage', 'timeOnSite', 'visitors', 'visits']],
                      ['Content', ['uniquePageviews']]
                    ]
  end
  def reports_list
    report_list = []
    Dir.foreach [Rails.root.to_s, 'lib/google_analytics'].join('/') do |file|
      unless file[0] == "."
        report_list << file.split(".").first.humanize
      end
    end
    return report_list 
  end

  def agents_list
    agents = @office.agents.map{|agent| [agent.display_name, agent.uuid]}
  end

  def agents_with_listings_list
    agents = []
    @office.agents.each do |agent|
      if WmsSvcConsumer::Models::Listing.find_all_by_agent(agent.uuid).results.count > 0
        agents << [agent.display_name, agent.uuid]
      end
    end
    return agents
  end
  def date_results(reports, listing_id)
    date_oriented_result = []
    for report in reports
      if report.uuid == listing_id
        date_oriented_result << [report.send(:date), report.send(:page_views), report.send(:unique_pageviews)] 
      end
    end
    return date_oriented_result[0].to_s + " page views: " + date_oriented_result[1].to_s + " unique views: " + date_oriented_result[2].to_s
  end
  
end
