Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{ENV['cbu_redis_server']}:6379/12", :namespace => ENV['cbu_redis_namespace'] }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{ENV['cbu_redis_server']}:6379/12", :namespace => ENV['cbu_redis_namespace'] }
end