require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["COMPOSE"]
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: {browser: :remote, url: "http://chrome-server:4444"}
  elsif ENV["HEADLESS"]
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  else
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  setup do
    if ENV["COMPOSE"]
      Capybara.server_host = "0.0.0.0"
      Capybara.app_host = "http://#{ENV.fetch("HOSTNAME")}:#{Capybara.server_port}"
      Capybara.default_max_wait_time = 6.seconds
    end
  end
end
