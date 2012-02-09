WmsSvcConsumer::Base.site = "#{Rails.application.config.service_url[:profile]}"
WmsSvcConsumer::Models::Listing.site = "#{Rails.application.config.service_url[:listing]}"
