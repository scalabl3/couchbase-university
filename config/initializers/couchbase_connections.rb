require 'couchbase'

Rails.logger.info "couchbase_connections.rb" if defined?(Rails) and Rails.logger

CBU = Couchbase.new(bucket: "cbu", node_list: ENV['cbu_couchbase_servers'].split(","))
CBD = Couchbase.new(bucket: "cbdocs", node_list: ENV['cbu_couchbase_servers'].split(","))

CBU.quiet = true
CBD.quiet = true 


Rails.logger.info CBU.inspect if defined?(Rails) and Rails.logger
Rails.logger.info CBD.inspect if defined?(Rails) and Rails.logger

#DocsNavTree.generate
#RenderNavTree.generate
