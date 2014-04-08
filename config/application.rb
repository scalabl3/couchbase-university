require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'log4r/formatter/patternformatter'
include Log4r

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module CouchbaseUniversity
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		# config.time_zone = 'Central Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :de
		
		
		config.sass.preferred_syntax = :sass
		
		cache_options = {
			:bucket => 'cbu',
			:username => 'cbu',
			:password => '',
			:expire_in => 60.minutes,
		}
		config.cache_store = :couchbase_store, cache_options
		
		session_options = {
			:expire_after => 60.minutes,
			:couchbase => {
				:bucket => 'cbu',
				:username => 'cbu',
				:password => '',
				:default_format => :marshal
			}
		}		 
		require 'action_dispatch/middleware/session/couchbase_store'
		config.session_store :couchbase_store, session_options
		
		config.generators do |g|
			g.orm = nil
			g.stylesheet_engine = :sass
			g.template_engine :erb
			#g.test_framework :rspec, :fixture => true, :views => false
			#g.fixture_replacement :factory_girl, :dir => "spec/factories"
		end

		config.assets.paths << Rails.root.join("vendor")			
		config.assets.paths << Rails.root.join("vendor/todo")

		
		#config.log_level = :unknown
		config.log_level = :info

		log4r_config = YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
		log_cfg = YamlConfigurator
		log_cfg.decode_yaml( log4r_config['log4r_config'] )
 
		config.logger = Log4r::Logger['rails']		
		config.logger.info "Application Initialized"
	end
end