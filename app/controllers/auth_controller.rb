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
			audience: "http://localhost:3000"
		}
		
		options = {
			body: data
		}
		response = Map.new(HTTParty.post("https://verifier.login.persona.org/verify", options))
		
		if response.status and response.status == "okay"
			session[:user].email = response.email
			session[:user].is_authenticated = true
		end
		
		unless CBU.get(response.email)
			id = CBU.incr("u::count", initial: 1001)
		
			user = {
				uid: id,
				doctype: "user",
				email: response.email,
				last_login: Time.now.to_i,
				created_at: Time.now.to_i
			}
			
			CBU.add("u::#{id}", user)
			
		end
		
		render js: "currentUser = \"jasdeep@scalabl3.com\";"
	end
	
	def persona_logout
		reset_session
	end
end
