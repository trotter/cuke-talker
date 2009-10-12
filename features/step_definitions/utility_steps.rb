When /^I set the host to "([^"])+"$/ do |url|
  $browser = ::Selenium::Client::Driver.new(Webrat.configuration.selenium_server_address || "localhost",
                                            Webrat.configuration.selenium_server_port,
                                            Webrat.configuration.selenium_browser_key,
                                            "http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port}")
end

When /^I go to "([^"]+)"$/ do |url|
  visit url
end

When /^I click xpath "([^"]+)"$/ do |xpath|
  locator = %Q|xpath=#{xpath}|
  browser.wait_for_element(locator, :timeout_in_seconds => 5)
  browser.click(locator)
end

