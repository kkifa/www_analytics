class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_office
  def get_office
    @office =  WmsSvcConsumer::Models::Office.find(7939473)
  end
end
