class SearchController < ApplicationController
  skip_before_filter :verify_authenticity_token
	include SearchHelper
  
  def results
		client = Elasticsearch::Client.new({ hosts: ENV['cbu_elasticsearch_servers'].split(","), log: true})
		
		if params[:search_words].start_with? "tags:" 
			tags = params[:search_words][5..-1]
			@type = "By Tags:  " + tags.downcase
 			@results = search_tags(tags)
		elsif params[:search_words].start_with? "t:" 
			tags = params[:search_words][2..-1]
			@type = "By Tags:  " + tags.downcase
			@results = search_tags(tags)
		else
			@type = "By Words: " + params[:search_words]
			@results = search_markdown(params[:search_words])
		end
				
		#ap @results
  end
end
