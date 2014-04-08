class VideosController < ApplicationController
	include VideosHelper
  skip_before_filter :verify_authenticity_token
  
  def index
		@videos = get_videos
  end
end
