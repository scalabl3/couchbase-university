module SearchHelper
	def search_markdown(words)
		client = Elasticsearch::Client.new log: true
		r = Map.new(client.search index: 'cbdocs', body: { query: { match: { markdown: words } } })
		
		keys = []
		keys = r.hits.hits.map { |doc| doc._source.meta.id }
		
		return Map.new({
			list: CBD.get(keys)
		})
	end
	
	def search_tags(words)
		client = Elasticsearch::Client.new log: true
		r = Map.new(client.search index: 'cbdocs', body: { query: { match: { tags: words } } })
		
		keys = []
		keys = r.hits.hits.map { |doc| doc._source.meta.id }
		
		return Map.new({
			list: CBD.get(keys)
		})                   
	end
end
