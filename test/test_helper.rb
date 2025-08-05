ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"
require "spy/integration"

VCR.configure do |config|
  config.cassette_library_dir = "test/cassettes"

  config.hook_into :webmock

  config.ignore_hosts("0.0.0.0")
  config.ignore_localhost = true

  config.before_record do |i|
    i.response.body.force_encoding("UTF-8")
  end

  config.filter_sensitive_data("<BEARER_TOKEN>") do |interaction|
    auths = interaction.request.headers["Authorization"]&.first
    if auths && (match = auths.match(/^Bearer\s+([^,\s]+)/))
      match.captures.first
    end
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
