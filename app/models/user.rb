class User < ModelBase

  attr_accessor :uid, :first_name, :last_name, :full_name, :username, :email
	attr_accessor :persona_uid, :twitter_uid, :github_uid
	attr_accessor :twitter_user, :twitter_token, :twitter_info
	attr_accessor :github_user, :github_token, :github_info
	attr_accessor :exists, :is_couchbase, :is_authenticated
	
	def initialize(attr = {})
		load_parameter_attributes(attr)
		@exists ||= false
		@is_couchbase ||= false
		@is_authenticated ||= false
		test_data
	end	
	
	def test_data
		@uid = 100001
		@first_name = "Jasdeep"
		@last_name = "Jaitla"
		@full_name = "Jasdeep Jaitla"
		@username = "scalabl3"
		@email = "jasdeep@scalabl3.com"
	end
	
	def toggle_authentication
		
		if @is_authenticated
			@is_authenticated = false 
		else
			@is_authenticated = true
		end
		
		self
	end
	
	def self.find(email)
		k = CBU.get(email)
		User.new(CBU.get(k))		
	end

end