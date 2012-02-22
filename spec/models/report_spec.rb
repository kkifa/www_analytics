require 'spec_helper'
describe Report do 
  it 'should be an openstruct object', :vcr do 
    report = Report.new('AgentListings')
    report.results.class.should be_an_instance_of OpenStruct
  end
end
