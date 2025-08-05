require "ruby_llm"

RubyLLM.configure do |config|
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", Rails.application.credentials.openai_api_key || "no-api-key-provided")
end
