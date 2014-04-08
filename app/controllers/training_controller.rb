class TrainingController < ApplicationController
	include TrainingHelper
  skip_before_filter :verify_authenticity_token
  
  def index
		@training = get_training		
  end

	def course
		@course = Map.new(CBU.get("training::#{params[:id]}"))
		@desc = MarkdownRender::render(@course.description)
	end
end
