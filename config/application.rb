require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dates
	CFP_LIGHTNING_BEGINS = Date.parse("2019-09-15")
	CFP_LIGHTNING_ENDS = Date.parse("2019-11-01")
	CFP_TUTORIALS_BEGINS = Date.parse("2019-09-15")
	CFP_TUTORIAL_ENDS = Date.parse("2019-11-01")
  CONFERENCE_YEAR = 2020
  CONFERENCE_DATES = "March 18-20 #{CONFERENCE_YEAR}"
  CONFERENCE_DATES_NO = "18-20 mars #{CONFERENCE_YEAR}"
  CONFERENCE_DATE_KIDS = "Søndag 15. mars #{CONFERENCE_YEAR}"
end

module Booster2013
  class Application < Rails::Application
    include Dates
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    #config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib/cache)
    config.autoload_paths += %W(#{config.root}/app/models/user)
    config.autoload_paths += %W(#{config.root}/app/pdfs)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    config.active_record.time_zone_aware_types = [:datetime, :time]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec
    end
    config.active_record.sqlite3.represent_boolean_as_integer = true

  end
end
