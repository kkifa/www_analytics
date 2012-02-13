require 'spec_helper'

describe Listing, "listing model" do 
  it 'converts analytics reports aggregated listing values' do 
    listing = Listing.new(123456)
    listing.should have_at_most(1).aggregate_listing
  end
end
