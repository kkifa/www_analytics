class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_office
  def current_office
    @office ||=  WmsSvcConsumer::Models::Office.find(7939473)
  end
end
