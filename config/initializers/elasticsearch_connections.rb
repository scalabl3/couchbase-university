require 'elasticsearch'

ES = Elasticsearch::Client.new({ 
					hosts: ENV['cbu_elasticsearch_servers'].split(","), 
					log: true,
					logger: Log4r::Logger['production_es']
		 })