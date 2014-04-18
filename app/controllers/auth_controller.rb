class AuthController < ApplicationController	
	layout false
	
  def login
  end

  def logout
  	reset_session
	end

	def persona_login
		data = {
			assertion: params[:assertion],
			audience: ENV['cbu_persona_audience']
		}
		
		response = Map.new(HTTParty.post("https://verifier.login.persona.org/verify", 
												:body => data.to_json,
    										:headers => { 'Content-Type' => 'application/json' } ))
		
		Rails.logger.info data.to_json
		Rails.logger.info response.inspect
		
		if response.status and response.status == "okay"

			u = User.find(response.email)
			
			unless u
				u = User.new({
					email: response.email.downcase,
					persona_uid: response.email.downcase
				})
				u.save
			end
			
			u.authenticate
			
			session[:user] = u
			session[:user].email = response.email
			
			render js: "currentUser = \"#{response.email.downcase}\";"
		
		else
			render js: { error: true, response: response, data: data }
		end
		

	end
	
	def persona_logout
		reset_session
	end
end
