require 'spec/expectations'
require 'webrat'

Webrat.configure do |config|
  config.mode = :selenium
  config.application_port = 80
  config.application_address = "www.google.com"
  config.application_framework = :external
end

World do
  session = Webrat::SeleniumSession.new
  session.extend(Webrat::Methods)
  session.extend(Webrat::Selenium::Methods)
  session.extend(Webrat::Selenium::Matchers)
  session
end

