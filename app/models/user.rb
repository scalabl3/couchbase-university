class User < ModelBase

  attr_accessor :uid, :first_name, :last_name, :full_name, :username, :email
	attr_accessor :persona_uid, :twitter_uid, :github_uid
	attr_accessor :twitter_user, :twitter_token, :twitter_info
	attr_accessor :github_user, :github_token, :github_info
	attr_accessor :exists, :is_couchbase, :is_authenticated
	attr_accessor :created_at, :last_login
	
	def initialize(attr = {})
		attr = Map.new(attr)
		load_parameter_attributes(attr)
		@exists ||= false
		@is_couchbase ||= false
		@is_authenticated ||= false
		test_data if attr.use_test_data?
	end	
	
	def test_data
		@uid = 100001
		@first_name = "Jasdeep"
		@last_name = "Jaitla"
		@full_name = "Jasdeep Jaitla"
		@username = "scalabl3"
		@email = "jasdeep@scalabl3.com"
	end
	
	def save
		if @uid
			CBU.replace("u::#{@uid}", self.to_json)
		else
			@uid = User.create_uid
			CBU.add("u::#{@uid}", self.to_json)
			CBU.add("#{@email}", @uid)
		end
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
		return nil unless k
		User.new(CBU.get("u::#{k.to_s}"))		
	end

	def self.create_uid
		CBU.incr("u::count", initial: 1001)
	end
	
end