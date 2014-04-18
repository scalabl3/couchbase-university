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
		
		Rails.logger.info response.inspect
		
		if response.status and response.status == "okay"
			session[:user].email = response.email
			session[:user].is_authenticated = true
		end
		
		if response.email? and !CBU.get(response.email)
			id = CBU.incr("u::count", initial: 1001)
		
			user = {
				uid: id,
				doctype: "user",
				email: response.email,
				last_login: Time.now.to_i,
				created_at: Time.now.to_i
			}
			
			CBU.add("u::#{id}", user)
			CBU.add("response.email", "u::#{id}")
			
		end
		
		render js: "currentUser = \"jasdeep@scalabl3.com\";"
	end
	
	def persona_logout
		reset_session
	end
end
