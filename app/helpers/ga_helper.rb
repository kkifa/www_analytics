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
        report_list << file.split(".").first.gsub("_", " ")
      end
    end
    return report_list 
  end

  def agents_list
    agent_list = 
      [
        ["agent 1", 1 ],
        ["agent 2", 2 ],
        ["agent 3", 3 ],
        ["agent 4", 4 ],
        ["agent 5", 5 ],
      ]
  end
  
end
