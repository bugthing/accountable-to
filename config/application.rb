require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AccountableTo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks puma])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    #  --- custom config ---
    app_host = ENV.fetch("APP_HOST", `hostname`.strip&.downcase || "localhost")

    # Specify outgoing SMTP server. Remember to add smtp/* credentials via rails credentials:edit.
    config.action_mailer.smtp_settings = {
      user_name: Rails.application.credentials.dig(:smtp, :user_name),
      password: Rails.application.credentials.dig(:smtp, :password),
      address: Rails.application.credentials.dig(:smtp, :address) || "smtp.gmail.com",
      port: Rails.application.credentials.dig(:smtp, :port) || "587",
      authentication: :plain,
      enable_starttls_auto: true,
      domain: Rails.application.credentials.dig(:smtp, :domain) || app_host
    }

    config.action_mailer.default_url_options = {host: app_host}
    routes.default_url_options = config.action_mailer.default_url_options
  end
end
