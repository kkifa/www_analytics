class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_office
  def current_office
    if params[:office_slug]
      @office = WmsSvcConsumer::Models::Office.find_by_slug(params[:office_slug])
    else
      @office ||=  WmsSvcConsumer::Models::Office.find(8008563)
    end
  end
end
