module AuthenticationHelper

	 def check_session
			#Rails.logger.info ("session[:user] = #{session[:user].class.to_s} .nil? #{session[:user].nil?}")
			
			if session[:user].nil?
				Rails.logger.info ("Create New User in Session")
				session[:user] = User.new 
			end
			
			#Rails.logger.info ("check-session #{session[:user].is_authenticated}")
			#p session[:user] 		  

			#Rails.logger.info ("toggle authentication state")
			
			#p session[:user]
			
			#Rails.logger.info ("check-session #{session[:user].is_authenticated}")
			
	 end

end