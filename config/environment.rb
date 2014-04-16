# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'dotenv'
Dotenv.load! ".env"
CB_SERVERS=ENV['cbu_couchbase_servers'].split(",")
puts ENV['cbu_couchbase_servers']

# Initialize the Rails application.
CouchbaseUniversity::Application.initialize!
