# def time_in_ms(start, finish)
#   return (((finish - start).to_f * 100000).round / 100.0 ).to_s
# end
#  
# ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
#  
#   logger = Log4r::Logger['rails']
#  
#   controller_format = "@method @status @path @durationms"
#  
#   if !payload[:exception].nil? || payload[:status] == 500
#     #["process_action.action_controller", 0.033505, "b4ebe16ef3da4c5eb902", {:controller=>"MongotestController", :action=>"index", :params=>{"action"=>"index", "controller"=>"mongotest"}, :format=>:html, :method=>"GET", :path=>"/mongotest", :exception=>["Mongoid::Errors::DocumentNotFound", "\nPro   ...  "]}
#     logger.error { 
#       message = controller_format.clone
#       message.sub!(/@status/, payload[:status].to_s)
#       message.sub!(/@method/, payload[:method])
#       message.sub!(/@path/, payload[:path])
#       message.sub!(/@duration/, time_in_ms(start,finish))
#       message += " EXCEPTION: #{payload[:exception]}"
#       message
#     }
#   end
#  
#   if payload[:status] != 200 && payload[:status] != 500 && payload[:exception].nil?
#     logger.warn { 
#       message = controller_format.clone
#       message.sub!(/@status/, payload[:status].to_s)
#       message.sub!(/@method/, payload[:method])
#       message.sub!(/@path/, payload[:path])
#       message.sub!(/@duration/, time_in_ms(start,finish))
#       message += " EXCEPTION: #{payload[:exception]}"
#       message
#     }
#   end
#  
#   if payload[:status] == 200 && time_in_ms >= 500
#     logger.warn { 
#       message = controller_format.clone
#       message.sub!(/@status/, payload[:status].to_s)
#       message.sub!(/@method/, payload[:method])
#       message.sub!(/@path/, payload[:path])
#       message.sub!(/@duration/, time_in_ms(start,finish))
#       message
#     }
#   end
#  
#   if payload[:status] == 200 && time_in_ms < 2000
#     logger.info { 
#       message = controller_format.clone
#       message.sub!(/@status/, payload[:status].to_s)
#       message.sub!(/@method/, payload[:method])
#       message.sub!(/@path/, payload[:path])
#       message.sub!(/@duration/, time_in_ms(start,finish))
#       message
#     }
#   end
#  
#   #logger.
#   logger.debug {
#     db = (payload[:db_runtime] * 100).round/100.0 rescue "-"
#     view = (payload[:view_runtime] * 100).round/100.0 rescue "-"
# 		#params = { PARAMS: "#{payload[:params].to_json" }
#     "TIMING[ms]: sum:#{time_in_ms(start,finish)} db:#{db} view:#{view}" 
#   }
#  
# end