require 'feedjira'
require 'pp'

class MainController < ApplicationController
	before_filter :check_session, :except => :logout
  skip_before_filter :verify_authenticity_token, :logout
  
  def index
		Rails.logger.info ("\n\n\n")
		#session[:user] = session[:user].toggle_authentication
		Rails.logger.info ("index #{session[:user].is_authenticated}")
  end

  def logout
		reset_session
		redirect_to "/"
  end
  
  def sofeed
    
    @feed = { error: "didn't work" }
    
    unless CBU.get("so::questions::refresh")
      puts "=======>> Refreshing SO Question List"      
      StackOverflow.perform_async('cbu', ENV['cbu_couchbase_servers'].split(","), 60)
    else
      puts "=======>> Using Existing SO Question List"
    end
    
    @feed = CBU.get("so::questions")
    
    render layout: false, json: @feed
  end
end
