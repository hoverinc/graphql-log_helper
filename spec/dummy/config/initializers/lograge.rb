require 'lograge'

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    Graphql::LogHelper.log_details(event.payload[:params])
  end
end
