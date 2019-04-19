require "rspec/expectations"
require "appium_lib"
require "rspec"
require "sauce_whisk"
require "selenium-webdriver"
require "require_all"

require_rel "../pages"

RSpec.configure do |config|

  config.before(:each) do |example|
    caps = {
        testobject_api_key: ENV['SAUCE_API_KEY'],
        platformName: ENV['platformName'],
        platformVersion: ENV['platformVersion'],
        deviceName: ENV['deviceName'],
        testobject_test_name: example.full_description
    }

    appium_lib = {server_url: ENV['APPIUM_URL']}

    @driver = Appium::Driver.new(caps: caps, appium_lib: appium_lib)

    @driver.start_driver
    @sessionid = @driver.session_id
  end

  config.after(:each) do |example|
    url = "https://#{ENV['SAUCE_API_KEY']}:#{'blank'}@app.testobject.com/api/rest/v1/appium/session/#{@sessionid}/test"

    call = {url: url,
            method: :put,
            verify_ssl: false,
            payload: JSON.generate(passed: !example.exception),
            headers: {'Content-Type' => 'application/json',
                      'Accept' => 'application/json'}
    }
    RestClient::Request.execute(call) do |response, request, result|
      raise unless response.code == 200 || response.code == 201
      puts response.code == 200 ? "PASSED" : "FAILED"
    end

    @driver.driver_quit
  end

end
