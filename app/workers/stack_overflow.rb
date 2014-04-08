require 'httparty'
require 'couchbase'
require 'json'
require 'map'

class StackOverflow
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :misc
  
  def perform(bucket, node_list, ttl)
    puts "Performing..."
    
    cb = Couchbase.new(bucket: bucket, node_list: node_list)

    so_questions = []
    quota_rem = 0
    quota_max = 0
    
    urls = ["https://api.stackexchange.com/2.1/questions?order=desc&sort=activity&tagged=couchbase&site=stackoverflow&filter=!.Ib0XQoCmqq5hSs-ZI6WHz1lJB6bT&key=ENyiQdOmgwwCU35W1Z1Vkw((",
      "https://api.stackexchange.com/2.1/questions?order=desc&sort=activity&tagged=couchbase-view&site=stackoverflow&filter=!.Ib0XQoCmqq5hSs-ZI6WHz1lJB6bT&key=ENyiQdOmgwwCU35W1Z1Vkw((",
      "https://api.stackexchange.com/2.1/questions?order=desc&sort=activity&tagged=couchbase-lite&site=stackoverflow&filter=!.Ib0XQoCmqq5hSs-ZI6WHz1lJB6bT&key=ENyiQdOmgwwCU35W1Z1Vkw(("]
    urls.each do |u|
      r = HTTParty.get(u)
      
       i = Map.new(JSON.parse(r.body)) 

       i.items.each do |q|
         so_questions << q
       end
       
       quota_rem = i.quota_remaining
       quota_max = i.quota_max            
    end
        
    so_questions.sort! { |a, b| b.last_activity_date <=> a.last_activity_date }
        
    cb.set("so::questions", { items: so_questions, quota_max: quota_max, quota_remaining: quota_rem })
    cb.set("so::questions::refresh", true, :ttl => ttl)
    
    puts "#{quota_rem}/#{quota_max}, won't update for #{ttl} seconds"
  end
  
end