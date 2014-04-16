# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'dotenv'
Dotenv.load! ".env"

# Initialize the Rails application.
CouchbaseUniversity::Application.initialize!
